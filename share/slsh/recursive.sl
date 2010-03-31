define recursive ();

define recursive (source_dir, interactive)
{
  variable local_interactive = int (interactive) - 48,
    filelist_array = listdir (source_dir);

  list_insert (file_list, source_dir);

  variable absolute_path = String_Type [length (filelist_array)]; absolute_path[*] = source_dir;

  filelist_array = array_map (String_Type, &path_concat, absolute_path, filelist_array);

  variable index, file;

  _for index (0, length (filelist_array) -1, 1)
    {
      file = filelist_array[index];

      ifnot (__is_directory (file))
        {
          list_insert (file_list, file);
          continue;
        }

      if ((local_interactive) && (1 != get_yn ("%s: descend into directory `%s'\n",
           path_basename (__argv[0]), file)))
           continue;

      recursive (file, interactive);
    }
}

