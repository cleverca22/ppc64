#include <assert.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char **argv) {
  uint64_t offset = 0x200c8000000ULL;
  uint64_t size = 16;
  printf("0x%lx\n", offset);

  int fd = open("/dev/mem", O_RDONLY);
  assert(fd >= 0);
#if 0
  offset = lseek(fd, offset, SEEK_SET);
  printf("0x%lx\n", offset);
  uint8_t *buffer = malloc(size);
  assert(buffer);
  int ret = read(fd, buffer, size);
  if (ret == -1) perror("failed to read");
#else
  uint8_t *buffer = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, offset);

  int outfd = open("dump.bin", O_WRONLY|O_CREAT, 0777);
  write(outfd, buffer, size);
  close(outfd);
#endif
}
