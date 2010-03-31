
variable
  Mkdir_Version = "0.1.0",
  Mkdir_Verbose = 0,
  Mkdir_Parents = 0,
  Mkdir_Mode = 0,
  Mkdir_Abort = 0;

()= evalfile ("mkdir");

define _mkdir ()
{
  variable v, dirs, args = __pop_list (_NARGS);
  ifnot (length (args))
    {
      get_doc_string_from_file (get_doc_files[0], "_mkdir");
      ()= fprintf (stdout, "\n_mkdir Version: %s\n", Mkdir_Version);
      return 0;
   }

  if (1 < length (args) && string_match (char(args[0][0]), "-", 1))
    {
      _for v (0, strlen (args[0]) -1, 1)
        {
          switch (args[0][v])
            {case 'v': Mkdir_Verbose = 1;}
            {case 'p': Mkdir_Parents = 1;}
            {case 'm': Mkdir_Mode = args[1];}
            {case 'x': Mkdir_Abort = 1;}
        }

      ifnot (Mkdir_Mode)
        dirs = args[[1:length (args) -1]];
      else
        dirs = args[[2:length (args) -1]];
    }
  else
    dirs = args[[0:length (args) -1]];

  variable exit_code = 0;
  foreach (dirs)
    {
      variable dir = ();
      if (-1 == mkdir_main (dir))
        {
          exit_code = -1;
          if (Mkdir_Abort)
            break;
        }
    }

  Mkdir_Verbose = 0, Mkdir_Parents = 0, Mkdir_Mode = 0, Mkdir_Abort = 0;

  return exit_code;
}
