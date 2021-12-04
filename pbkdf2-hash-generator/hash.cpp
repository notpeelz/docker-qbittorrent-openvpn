#include <iostream>
#include <cstdlib>
#include <signal.h>
#include <string>
#include <fstream>
#include <vector>
#include <openssl/evp.h>

#define HASH_ITERATIONS (100000)
#define HASH_METHOD (EVP_sha512())
#define SALT_LENGTH 16

static const std::string base64_chars =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  "abcdefghijklmnopqrstuvwxyz"
  "0123456789+/";

std::string base64_encode(unsigned char const* buf, unsigned int bufLen) {
  std::string ret;
  int i = 0;
  int j = 0;
  unsigned char char_array_3[3];
  unsigned char char_array_4[4];

  while (bufLen--) {
    char_array_3[i++] = *(buf++);
    if (i == 3) {
      char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
      char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
      char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
      char_array_4[3] = char_array_3[2] & 0x3f;

      for (i = 0; i < 4; i++) {
        ret += base64_chars[char_array_4[i]];
      }
      i = 0;
    }
  }

  if (i) {
    for(j = i; j < 3; j++) {
      char_array_3[j] = '\0';
    }

    char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
    char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
    char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
    char_array_4[3] = char_array_3[2] & 0x3f;

    for (j = 0; j < i + 1; j++) {
      ret += base64_chars[char_array_4[j]];
    }

    while (i++ < 3) {
      ret += '=';
    }
  }

  return ret;
}

bool generate_salt(unsigned char* value, int len) {
  std::ifstream urandom("/dev/urandom", std::ios::in | std::ios::binary);
 
  if (!urandom.is_open()) {
    std::cerr << "Failed to open /dev/urandom" << std::endl;
    return false;
  }

  if (!urandom.read((char*)value, len).good()) {
    std::cerr << "Failed to read from /dev/urandom" << std::endl;
    return false;
  }

  urandom.close();
  return true;
}

void handle_sigint(int s) {
  std::exit(128 + SIGINT);
}

int main(int argc, char** argv) {
  struct sigaction sigint_handler;

  sigint_handler.sa_handler = handle_sigint;
  sigemptyset(&sigint_handler.sa_mask);
  sigint_handler.sa_flags = 0;

  sigaction(SIGINT, &sigint_handler, NULL);

  unsigned char salt[SALT_LENGTH];
  if (!generate_salt(salt, SALT_LENGTH)) return 1;

  std::string password;
  getline(std::cin, password);

  #define BUFFER_SIZE 64
  unsigned char out[BUFFER_SIZE];

  int result = PKCS5_PBKDF2_HMAC(
    password.data(), password.length(),
    (const unsigned char*) salt, SALT_LENGTH,
    HASH_ITERATIONS, HASH_METHOD,
    BUFFER_SIZE, (unsigned char*)&out
  );

  if (!result) {
    std::cerr << "Failed to compute password hash" << std::endl;
    return 1;
  }

  std::string password_b64 = base64_encode(out, BUFFER_SIZE);
  std::string salt_b64 = base64_encode(salt, SALT_LENGTH);

  std::cout << salt_b64 << ":" << password_b64 << std::endl;
  return 0;
}
