
define cp_file (source, dest)
{
  variable
    backuptext = "", backup,
    st_source = stat_file (source),
    st_dest = stat_file (dest);

  if (NULL != st_dest)
    {
      if (Cp_Noclobber)
        return 0;

      if (Cp_Interactive && (1 != get_yn ("%s: overwrite `%s'?\n", path_basename (__argv[0]), dest)))
        return 0;

      if (Cp_Backup)
        {
          backup = strcat (dest, Cp_Suffix);

          if (-1 == rename (dest, backup))
            {
              ()= fprintf (stderr, "%s: cannot backup `%s': %s\n",
                           path_basename (__argv[0]), dest, errno_string (errno));
              return -1;
            }

          if (__is_file_executable (dest))
            chmod (backup, 0755);

          backuptext = sprintf ("(backup: `%s')", backup);
        }
    }

  variable e;
  try (e)
    {
      copy_file (source, dest);
    }
  catch OpenError:
    {
      ()= fprintf (stderr, "Caught: %s\nMessage: %s\n", e.descr, e.message);
      if (__is_initialized (&backup))
        ()= remove (backup);
      return -1;
    }
  catch WriteError:
    {
      ()= fprintf (stderr, "%s: Unable to write in `%s'\n",
          path_basename (__argv[0]), dest);
      ()= fprintf (stderr, "Caught: %s\nMessage: %s\n", e.descr, e.message);

      if (__is_initialized (&backup))
        ()= remove (backup);

      return -1;
    }
  catch ReadError:
    {
      ifnot (__is_same(e.message, "Is a directory"))
        {
          ()= fprintf (stderr, "%s: couldn't read `%s'. Aborting ... ",
                       path_basename (__argv[0]),  source);
          if (__is_initialized (&backup))
            ()= remove (backup);
          return -1;
        }
      else
        {
          ()= fprintf (stderr, "%s: omitting directory `%s'\n",
                       path_basename (__argv[0]), source);
          if (__is_initialized (&backup))
            ()= remove (backup);
          return -1;
        }
    }
  catch IOError:
    {
      ()= fprintf (stderr, "%s: Unable to close the` %s'\n",
           path_basename (__argv[0]), dest);
      ()= fprintf (stderr, "Caught: %s\nMessage: %s\n", e.descr, e.message);

      ()= remove(dest);

      if (__is_initialized (&backup))
        ()= remove (backup);

      return -1;
    }

   if (Cp_Verbose)
     ()= fprintf (stdout, "`%s' -> `%s' %s\n", source, dest, backuptext);

   if (__is_file_executable (source))
     chmod (dest, 0755);

   return 0;

}

define cp_recursive (source, dest, destname)
{
  recursive (source, '0');
  variable source_file, dest_file, exit_code = 0;
  list_reverse (file_list);

  if (__is_directory (destname) && 0 == __is_same (".", dest))
    destname = path_concat (destname, path_basename (source));

  while (length (file_list))
    {
      source_file = list_pop (file_list);
      (dest_file, ) = strreplace (source_file, source, destname, 1);

      if (__is_directory (source_file))
        {
          ifnot (__is_directory (dest_file))
            {
              if (-1 == mkdir (dest_file))
                {
                  ()= fprintf (stderr, "%s: %s\n", path_basename (__argv[0]),
                      errno_string (errno));
                  return -1;
                  break;
                }
             }
           continue;
        }

      exit_code = cp_file (source_file, dest_file);
      if (-1 == exit_code)
        return -1;
    }

  return 0;
}

define copy (files, dest)
{
  variable st, index, source, st_source,
    exit_code = 0,
    source_len = length (files),
    st_dest = stat_file (dest),
    isdir_dest = __is_directory (dest);

  if (NULL == st_dest || 0 == isdir_dest)
    if (1 < source_len)
      {
        ()= fprintf (stderr, "%s: target `%s' is not a directory\n",
            path_basename (__argv[0]), dest);
         exit (1);
      }

  _for index (0, source_len - 1, 1)
     {
       variable destname = dest;
       source = strtrim_end (files[index], "/");
       st_source = stat_file (source);
       variable isdir_source = __is_directory (source);

       if (NULL == st_source)
         {
           ()= fprintf (stderr, "%s: cannot stat `%s': No such file or directory\n",
               path_basename (__argv[0]), source);
           exit_code = -1;
           continue;
         }

       if ((source == dest)
          || ((st_dest != NULL)
          && (st_source.st_ino == st_dest.st_ino)
          && (st_source.st_dev == st_dest.st_dev)))
         {
           ()= fprintf (stderr, "%s: `%s' and `%s' are the same file\n",
                        path_basename (__argv[0]), source, dest);
           exit_code = -1;
           continue;
         }

       if (NULL != st_dest && 0 == isdir_dest)
         if (isdir_source)
           {
             ()= fprintf (stderr, "%s: cannot overwrite non directory `%s' with directory `%s'\n",
                 path_basename (__argv[0]), dest, source[0]);
             exit_code = -1;
             continue;
           }

       if ((Cp_Update && NULL != st_dest))
         if (0 <= mtime_cmp (st_source, st_dest))
           continue;

       if (__is_same (".", dest))
         destname = path_basename (source);

       if (isdir_source)
         ifnot (Cp_Recursive)
           {
             ()= fprintf (stderr, "%s: omitting directory `%s'\n",
                 path_basename (__argv[0]), source);
              exit_code = -1;
              continue;
           }
         else
           {
             if (-1 == cp_recursive (source, dest, destname))
               exit_code = -1;

             continue;
           }

       if (__is_directory (destname))
         destname = path_concat (destname, path_basename (source));

       if (-1 == cp_file (source, destname))
         {
           exit_code = 1;
           continue;
         }
     }

  return exit_code;
}
