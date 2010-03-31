
define uname_all (s)
{
  variable name, a = "";
  foreach (get_struct_field_names (s))
    {
      name = ();
       a = strcat(a, " ", get_struct_field(s, name));
    }

  return a;
}

define uname_processor ()
{
  variable fp, pos, buf;
  fp = fopen ("/proc/cpuinfo", "r");
  while (-1 != fgets(&buf, fp))
   if (string_match (buf, "model name.*: ", 1))
     break;

  (, pos) = string_match_nth (0);

  return buf[[pos:]];

}

define uname_main(opt)
{
  variable s = uname();
  switch (opt)
    {case "a": Uname_Text = uname_all (s);}
    {case "s": Uname_Text = strcat (Uname_Text, " ", s.sysname);}
    {case "n": Uname_Text = strcat (Uname_Text, " ", s.nodename);}
    {case "r": Uname_Text = strcat (Uname_Text, " ", s.release);}
    {case "v": Uname_Text = strcat (Uname_Text, " ", s.version);}
    {case "m": Uname_Text = strcat (Uname_Text, " ", s.machine);}
    {case "p": Uname_Text = strcat (Uname_Text, " ", uname_processor ());}

}
