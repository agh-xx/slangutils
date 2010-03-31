private define mv_file (source, dest)
{
  variable backuptext = "", backup, st_dest = stat_file (dest);

  if (NULL != st_dest)
    {
      if (Mv_Noclobber)
        return 0;

      if (Mv_Interactive && (1 != get_yn ("%s: overwrite `%s'?\n", path_basename (__argv[0]), dest)))
        return 0;

      if (Mv_Backup)
        {
          backup = strcat (dest, Mv_Suffix);

          if (-1 == rename (dest, backup))
            {
              ()= fprintf (stderr, "%s: cannot backup `%s': %s\n",
                  path_basename (__argv[0]), dest, errno_string (errno));
              return -1;
            }

          if (__is_file_executable (dest))
            chmod (backup, 0755);

          backuptext = sprintf (" (backup: `%s')", backup);
        }
    }

  variable exit_code = rename (source, dest);
  if ((-1 == exit_code) &&
     ((__is_same (errno_string (errno), "Cross-device link")) &&
     (0 == __is_directory (source))))
    {
      if (0 == cp_file (source, dest))
        {
          if (__is_file_executable (dest))
            chmod (backup, 0755);

          if (-1 == remove (source))
            {
              ()= fprintf (stderr, "%s: cannot remove `%s': `%s'\n",
                  path_basename (errno_string (errno)));

              if (Mv_Backup)
                ()= remove (backup);

              return -1;
            }

          if (Mv_Verbose)
            ()= fprintf (stdout, "`%s' -> `%s' %s\n", source, dest, backuptext);

          return 0;
        }
      else
        {
          if (Mv_Backup)
            ()= remove (backup);

          ()=fprintf (stderr, "%s: cannot move `%s' to `%s': %s\n",
                      path_basename (__argv[0]), source, dest, errno_string (errno));

          return -1;
       }
    }
  else if (-1 == exit_code)
    {
      if (Mv_Backup)
        ()= remove (backup);

      ()=fprintf (stderr, "%s: cannot move `%s' to `%s': %s\n",
                  path_basename (__argv[0]), source, dest, errno_string (errno));

      return -1;
    }
  else
    {
      if (Mv_Verbose)
        ()= fprintf (stdout, "`%s' -> `%s'%s\n", source, dest, backuptext);

      if (__is_file_executable (source))
            chmod (dest, 0755);

      return 0;
    }
}

define mv_dir (source, dest, destname)
{
  variable backuptext = "";

  if (__is_directory (destname) && Mv_Backup)
    {
      variable backup = strcat (destname, Mv_Suffix);
      ifnot (__is_dir_empty (backup))
        {
          ()= fprintf (stderr, "%s: cannot backup `%s': Directory not empty\n",
              path_basename (__argv[0]), backup);
          return -1;
        }

      if (-1 == cp_recursive (destname, dest, backup))
        return -1;

      backuptext = sprintf (" (backup: `%s')", backup);
    }

  variable exit_code = cp_recursive (source, dest, destname);
  if (-1 == exit_code)
    return -1;

  if (-1 == rm_main ([source]))
    return -1;

  if (Mv_Verbose)
    ()= fprintf (stdout, "`%s' -> `%s'%s\n", source, destname, backuptext);

  return 0;
}

define mv_main (files, dest)
{
  variable index, destname, exit_code = 0,
    source_len = length (files),
    st_dest = stat_file (dest);

  if (NULL == st_dest || 0 == __is_directory (dest))
    if (source_len != 1)
      {
        () = fprintf (stderr, "%s: target `%s' is not a directory\n",
             path_basename (__argv[0]), dest);
        return -1;
      }

  _for index (0, source_len -1, 1)
    {
      destname = dest;
      variable source = files[index],
      st_source = stat_file (source);
      if (__is_same (".", dest))
        {
          destname = path_basename (source);
          st_dest = stat_file (destname);
        }

      if (st_source == NULL)
        {
          ()= fprintf (stderr,"%s: cannot stat `%s': No such file or a directory\n",
              path_basename (__argv[0]), source);
          exit_code = -1;
          continue;
        }

      if ((source == destname)
         || ((st_dest != NULL)
         && (st_source.st_ino == st_dest.st_ino)
         && (st_source.st_dev == st_dest.st_dev)))
        {
          ()= fprintf (stderr, "%s: `%s' and `%s' are the same file\n",
              path_basename (__argv[0]), source, destname);
          exit_code = -1;
          continue;
        }

      if (__is_directory (source))
        {
          if (-1 == mv_dir (source, dest, destname))
            exit_code = -1;

          continue;
        }

      if ((Mv_Update && NULL != st_dest))
        if (0 <= mtime_cmp (st_source, st_dest))
          continue;

      if (__is_directory (dest))
        destname = path_concat (dest, path_basename (source));

      if ( -1 == mv_file (source, destname))
        exit_code = -1;
    }

  return exit_code;
}
