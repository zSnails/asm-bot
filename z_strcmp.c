unsigned int z_strlen(const char *str) {
  unsigned int result = 0;
  for (int i = 0; *(str + i) != '\0'; i++) {
    result++;
  }
  return result;
}

_Bool z_strcmp(const char *a, const char *b) {
  unsigned int lena = z_strlen(a);
  unsigned int lenb = z_strlen(b);
  if (lena != lenb) {
    return 0;
  }
  for (int i = 0; i < lena; i++) {
    if (a[i] != b[i])
      return 0;
  }
  return 1;
}
