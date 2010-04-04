
define __is_directory (file)
{
  variable st = stat_file (file);
  if (NULL == st)
    return 0;

  return stat_is ("dir", st.st_mode);
}

define __is_file_symlink (file)
{
  variable st = lstat_file (file);
  if (NULL == st)
    return 0;

  return stat_is ("lnk", st.st_mode);
}

define __is_file_executable (file)
{
  ifnot (access (file, X_OK))
    return 1;

  return 0;
}

define __is_file_readable (file)
{
  ifnot (access (file, R_OK))
    return 1;

  return 0;
}

define __is_file_writable (file)
{
  ifnot (access (file, W_OK))
    return 1;

  return 0;
}

define __is_dir_empty (dir)
{
  variable filelist = listdir (dir);
  if (NULL == filelist || 0 == length (filelist))
    return 1;

  return 0;
}

define which (file, path_to_exec)
{
  variable path = getenv ("PATH");
  if (NULL == path)
    return 0;

  variable dir, abspath, path_array = strchop (path, path_get_delimiter (), 0);

  foreach (path_array)
    {
      dir = ();
      abspath = path_concat (dir, file);

      if (__is_file_executable (abspath))
        {
          @path_to_exec = abspath;
          return 1;
        }
    }

  return 0;
}
