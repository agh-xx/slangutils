variable
  Rm_Interactive = 0,
  Rm_Verbose = 0,
  Rm_Recursive = 0,
  Rm_Force = 0,
  file_list = {};

()= evalfile ("message");
()= evalfile ("dir");
()= evalfile ("recursive");
()= evalfile ("remove");


define rm ()
{
  variable v, args = __pop_list (_NARGS);
  ifnot (length (args))
    {
      get_doc_string_from_file (get_doc_files[0], "rm");
      return -1;
    }

  if (1 < length (args) && (NULL == stat_file (args[0])))
    {
      _for v (0, strlen (args[0]) -1, 1)
        {
          switch (args[0][v])
            {case 'i': Rm_Interactive = 1;}
            {case 'f': Rm_Force = 1;}
            {case 'v': Rm_Verbose = 1;}
            {case 'r': Rm_Recursive = 1;}
        }
      args = args[[1:length (args) -1]];
      if (Rm_Force && Rm_Interactive)
        Rm_Interactive = 0;
    }

  if (-1 == rm_main (args))
    {
      Rm_Interactive = 0, Rm_Force = 0, Rm_Verbose = 0, Rm_Recursive = 0;
      return -1;
    }

  Rm_Interactive = 0, Rm_Force = 0, Rm_Verbose = 0, Rm_Recursive = 0;

  return 0;
}
