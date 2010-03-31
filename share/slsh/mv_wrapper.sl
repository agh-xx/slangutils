variable
  Mv_Interactive = 0,
  Mv_Verbose = 0,
  Mv_Force = 0,
  Mv_Noclobber = 0,
  Mv_Backup = 0,
  Mv_Suffix = "~",
  Mv_Update = 0,
  Cp_Noclobber = 0,
  Cp_Interactive = 0,
  Cp_Backup = 0,
  Cp_Suffix = "~",
  Cp_Verbose = 0,
  Cp_Update = 0,
  Cp_Recursive = 1,
  Rm_Interactive = 0,
  Rm_Verbose = 0,
  Rm_Force = 0,
  Rm_Recursive = 1,
  file_list = {};

()= evalfile ("message");
()= evalfile ("file");
()= evalfile ("dir");
()= evalfile ("recursive");
()= evalfile ("stats");
()= evalfile ("copy");
()= evalfile ("remove");
()= evalfile ("move");

define mv ()
{
  variable v, source, dest, args = __pop_list (_NARGS);
  ifnot (length (args))
    {
      get_doc_string_from_file (get_doc_files[0], "mv");
      return -1;
    }

  if (2 < length (args) && (NULL == stat_file (args[0])))
    {
      _for v (0, strlen (args[0]) -1, 1)
        {
          switch (args[0][v])
            {case 'i': Mv_Interactive = 1;}
            {case 'f': Mv_Force = 1;}
            {case 'n': Mv_Noclobber = 1;}
            {case 'b': Mv_Backup = 1;}
            {case 'v': Mv_Verbose = 1;}
            {case 'u': Mv_Update = 1;}
        }

      source = args[[1:length (args) -2]], dest = args[-1];

      if (Mv_Force && Mv_Interactive)
        Mv_Interactive = 0;
    }
  else
    {
      source = args[[0:length (args) -2]];
      dest = args[-1];
    }

  if (-1 == mv_main (source, dest))
    {
      Mv_Interactive = 0, Mv_Verbose = 0, Mv_Force = 0, Mv_Noclobber = 0,
      Mv_Backup = 0, Mv_Update = 0;
      return -1;
    }

  Mv_Interactive = 0, Mv_Verbose = 0, Mv_Force = 0, Mv_Noclobber = 0,
  Mv_Backup = 0, Mv_Update = 0;

  return 0;
}
