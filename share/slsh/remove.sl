
define rm_file (file)
{
  if ((Rm_Interactive) && (1 != get_yn ("%s: remove regular file `%s'?\n",
       path_basename (__argv[0]), file)))
    return 0;

  if (-1 == remove (file))
    {
      ()= fprintf (stderr, "%s: cannot remove `%s': %s\n", path_basename (__argv[0]),
                   file, errno_string (errno));
      return -1;
    }

  if (Rm_Verbose)
    ()= fprintf (stdout, "%s: removed `%s'\n", path_basename (__argv[0]), file);

  return 0;
}

define rm_dir (dir)
{
  if ((Rm_Interactive) && (1 != get_yn ("%s: remove directory `%s'?\n",
       path_basename (__argv[0]), dir)))
    return 0;

  if (-1 == rmdir (dir))
    {
      ()= fprintf (stderr, "%s: cannot remove `%s': %s\n", path_basename (__argv[0]),
                   dir, errno_string (errno));
      return -1;
    }

  if (Rm_Verbose)
    ()= fprintf (stdout, "%s: removed `%s'\n", path_basename (__argv[0]), dir);

  return 0;
}

define rm_main (files)
{
  variable st, index, file, exit_code = 0, len = length (files);

  _for index (0, len - 1, 1)
    {
      file = files[index];
      st = stat_file (file);

      if (NULL == st)
        % check if it is a dangling link
        ifnot (__is_file_symlink (file))
          {
            if (Rm_Force)
              exit_code = 0;
            else
              {
                ()= fprintf (stderr, "%s: cannot remove `%s': No such file or directory\n",
                    path_basename (__argv[0]), file);
                exit_code = -1;
              }
            continue;
          }
        else
          {
            if (-1 == rm_file (file))
              exit_code = -1;

            continue;
          }

      if (0 == __is_file_writable (file) && 0 ==  __is_file_symlink (file))
        {
          ()= fprintf (stderr, "%s: cannot remove `%s': Permission denied\n",
              path_basename (__argv[0]), file);
          exit_code = -1;
          continue;
        }

      if (__is_directory (file) && 0 == __is_file_symlink (file))
        ifnot (Rm_Recursive)
          {
            ()= fprintf (stderr, "%s: omitting directory `%s'\n",
                path_basename (__argv[0]), file);
            exit_code = -1;
            continue;
          }
        else
          {
            recursive (file, char (Rm_Interactive + 48));
            variable item;
            while (length (file_list))
              {
                item = list_pop (file_list);
                if (__is_directory (item))
                  {
                    if (-1 == rm_dir (item))
                      exit_code = -1;
                  }
                else
                  {
                    if (-1 == rm_file (item))
                      exit_code = -1;
                  }
              }
            continue;
          }

      if (-1 == rm_file (file))
         exit_code = -1;
    }

  return exit_code;
}
