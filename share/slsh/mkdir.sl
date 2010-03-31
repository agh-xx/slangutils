
define mkdir_do(path)
{
  if (Mkdir_Mode)
    {
%  (BUG) intrinsic function can't pass the right mode
      if (-1 == mkdir (path,  Mkdir_Mode))
        {
          ()= fprintf (stderr, "%s: cannot create directory `%s': %s\n",
          path_basename (__argv[0]), path, errno_string (errno));
          return -1;
        }
    }
  else
    {
      if (-1 == mkdir (path))
        {
          ()= fprintf (stderr, "%s: cannot create directory `%s': %s\n", path_basename( __argv[0]),
                       path, errno_string (errno));
          return -1;
        }
    }

  if (Mkdir_Verbose)
    {
      ()= fprintf (stdout, "%s: created directory `%s'\n", path_basename (__argv[0]), path);
      return 0;
    }
  return 0;
}

define mkdir_main (path)
{
  variable root="", st_path = stat_file (path);

  if (NULL != st_path)
    {
      ifnot (Mkdir_Parents)
        {
          ()= fprintf (stderr, "%s: cannot create directory `%s': File exists\n",
              path_basename (__argv[0]),  path);
          return -1;
        }

      % Gnu mkdir returns 0
      return 0;
    }

  ifnot (Mkdir_Parents)
    {
      if (-1 == mkdir_do (path))
        return -1;

      return 0;
    }

  variable path_arr = strchop (path, '/', 0);
  if (0 == strlen (path_arr[0]))
    {
      path_arr[1] = strcat ("/", path_arr[1]);
      path_arr = path_arr[[1: length (path_arr) -1]];
    }

  variable newpath = "", p;
  foreach p (path_arr)
    {
      newpath = path_concat (newpath, p);
      st_path = stat_file (newpath);

      if (NULL == st_path)
        {
          if (-1 == mkdir_do (newpath))
            return -1;
        }
    }
  return 0;
}
