
variable passwd = struct
{
  pw_name, pw_pass, pw_uid, pw_gid, pw_gecos, pw_dir, pw_shell
};

define getpwnam (name)
{
  variable
    s = @passwd,
    line,
    lines,
    rec,
    fp = fopen ("/etc/passwd", "r");

  if (NULL == fp)
    return NULL;
  
  lines = fgetslines (fp);
  foreach line (lines)
    {
      rec = strchop (strtrim_end (line), ':', 0);
      if (__is_same (rec[0], name))
        {
          ifnot (7 == length (rec))
            return NULL;
          else
            set_struct_fields (s, rec[0], rec[1], rec[2], rec[3], rec[4], rec[5], rec[6]);

          return s;
        }
     }
   
   return NULL;
}

define getpwuid (uid)
{
  variable
    s = @passwd,
    line,
    lines,
    rec,
    fp = fopen ("/etc/passwd", "r");

  if (NULL == fp)
    return NULL;
  
  lines = fgetslines (fp);
  foreach line (lines)
    {
      rec = strchop (strtrim_end (line), ':', 0);
      if (__is_same (rec[2], string (uid)))
        {
          ifnot (7 == length (rec))
            return NULL;
          else
            set_struct_fields (s, rec[0], rec[1], rec[2], rec[3], rec[4], rec[5], rec[6]);

          return s;
        }
     }
   
   return NULL;
}

variable group = struct
{
  gr_name, gr_passwd, gr_gid, gr_mem
};

define getgrnam (name)
{
  variable
    s = @group,
    line,
    lines,
    rec,
    fp = fopen ("/etc/group", "r");

  if (NULL == fp)
    return NULL;
  
  lines = fgetslines (fp);
  foreach line (lines)
    {
      rec = strchop (strtrim_end (line), ':', 0);
      if (__is_same (rec[0], name))
        {
          ifnot (4 == length (rec))
            return NULL;
          else
            set_struct_fields (s, rec[0], rec[1], rec[2], rec[3]);

          return s;
        }
     }
   
   return NULL;
}

define getgrgid (gid)
{
  variable
    s = @group,
    line,
    lines,
    rec,
    fp = fopen ("/etc/group", "r");

  if (NULL == fp)
    return NULL;
  
  lines = fgetslines (fp);
  foreach line (lines)
    {
      rec = strchop (strtrim_end (line), ':', 0);
      if (__is_same (rec[2], string (gid)))
        {
          ifnot (4 == length (rec))
            return NULL;
          else
            set_struct_fields (s, rec[0], rec[1], rec[2], rec[3]);

          return s;
        }
     }
   
   return NULL;
}

define match_user (rec, name)
{
  variable a = strchop (rec, ',', 0);
  foreach (a)
    {
      variable u = ();
      if (__is_same (name, u))
        return 1;
    }

  return 0;
}

define getgrouplist (name)
{
  variable
    groups = {name},
    line,
    lines,
    rec,
    fp = fopen ("/etc/group", "r");

  if (NULL == fp)
    return NULL;
  
  lines = fgetslines (fp);
  foreach line (lines)
    {
      rec = strchop (strtrim_end (line), ':', 0);
      if (match_user (rec[-1], name) && 0 == __is_same (rec[0], name))
        list_append (groups, rec[0]);
    }
   
  return list_to_array (groups);
}

define getgrouplistgid (name, gid)
{
  variable
    groups = {gid},
    line,
    lines,
    rec,
    fp = fopen ("/etc/group", "r");

  if (NULL == fp)
    return NULL;
  
  lines = fgetslines (fp);
  foreach line (lines)
    {
      rec = strchop (strtrim_end (line), ':', 0);
      if (match_user (rec[-1], name) && 0 == __is_same (rec[2], gid))
        list_append (groups, string (rec[2]));
    }
   
  return list_to_array (groups);
}
