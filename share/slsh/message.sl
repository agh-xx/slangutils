
define print_error ()
{
  variable args = __pop_list (_NARGS);
  () = fprintf (stderr, "%s: ", __argv[0]);
  () = fprintf (stderr, __push_list (args));
}

define print_version (vers)
{
  () = fprintf (stdout, "Version: %S\n", vers);
}

define print_usage (opts)
{
  variable fp = stderr;
  foreach (opts)
    {
      variable opt = ();
      () = fputs (opt, fp);
    }
}

define get_yn ()
{
  variable args = __pop_list (_NARGS);
  () = fprintf (stdout, __push_list (args));
  () = fflush (stdout);

  variable yn;
  if (fgets (&yn, stdin) <= 0)
    return -1;

  "y" == strlow (strtrim (yn));
}
