
variable
  Cp_Interactive = 0,
  Cp_Verbose = 0,
  Cp_Force = 0,
  Cp_Backup = 0,
  Cp_Noclobber = 0,
  Cp_Suffix = "~",
  Cp_Update = 0,
  Cp_Recursive = 0,
  file_list = {};

()= evalfile ("dir");
()= evalfile ("message");
()= evalfile ("recursive");
()= evalfile ("stats");
()= evalfile ("file");
()= evalfile ("copy");


define cp ()
{
  variable v, source, dest, args = __pop_list (_NARGS);
  ifnot (length (args))
    {
      get_doc_string_from_file (get_doc_files[0], "cp");
      return -1;
    }

  if (2 < length (args) && (NULL == stat_file (args[0])))
    {
      _for v (0, strlen (args[0]) -1, 1)
        {
          switch (args[0][v])
            {case 'i': Cp_Interactive = 1;}
            {case 'f': Cp_Force = 1;}
            {case 'v': Cp_Verbose = 1;}
            {case 'u': Cp_Update = 1;}
            {case 'b': Cp_Backup = 1;}
            {case 'n': Cp_Noclobber = 1;}
            {case 'r': Cp_Recursive = 1;}
        }
      source = args[[1:length (args) -2]], dest = args[-1];

      if (Cp_Force && Cp_Interactive)
        Cp_Interactive = 0;
    }
  else
    {
      source = args[[0:length (args) -2]];
      dest = args[-1];
    }

  if (-1 == copy (source, dest))
    {
      Cp_Interactive = 0, Cp_Force = 0, Cp_Verbose = 0, Cp_Update = 0,
      Cp_Backup = 0, Cp_Noclobber = 0, Cp_Recursive = 0;
      return -1;
    }

  Cp_Interactive = 0, Cp_Force = 0, Cp_Verbose = 0, Cp_Update = 0,
  Cp_Backup = 0, Cp_Noclobber = 0, Cp_Recursive =0;

  return 0;
}
