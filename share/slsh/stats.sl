
define mtime_cmp (st_source, st_dest)
{
  if (st_source.st_mtime > st_dest.st_mtime)
    return -1;
  else if (st_source.st_mtime == st_dest.st_mtime)
    return 0;
  else
    return 1;

}

define file_size (file)
{
  variable st = stat_file (file);

  if (NULL != st)
    return st.st_size;

  return -1;
}
