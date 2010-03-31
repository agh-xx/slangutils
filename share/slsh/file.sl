
define fread_file (file, size)
{
  variable buf, fp;
  fp = fopen(file, "rb");

  if (fp == NULL)
    throw OpenError, "Unable to open the $file"$;

  if (-1 == fread(&buf, String_Type, size, fp))
    throw ReadError, errno_string(errno);

  if (-1 == fclose (fp))
    throw IOError, errno_string(errno);

  return buf;
}

define fwrite_file (file, buf)
{
  variable fp;
  fp = fopen(file, "wb");

  if (fp == NULL)
    throw OpenError, "Unable to open the $file"$;

  if (-1 == fwrite(buf, fp))
    throw WriteError, errno_string(errno);

  if (-1 == fclose (fp))
    throw IOError, errno_string(errno);
}

define copy_file (source, dest)
{
  variable
    buf,
    source_fp = fopen (source, "rb"),
    dest_fp = fopen (dest, "wb");

  if (NULL == source_fp)
    throw OpenError, "Unable to open the $source"$;

  if (NULL == dest_fp)
    throw OpenError, "Unable to open the $to"$;

  while (-1 != fread (&buf, String_Type, 1024, source_fp))
    if (-1 == fwrite(buf, dest_fp))
      throw WriteError, errno_string(errno);

  if (-1 == fclose (source_fp))
    throw IOError, errno_string(errno);

  if (-1 == fclose (dest_fp))
    throw IOError, errno_string(errno);

}
