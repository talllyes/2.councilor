<%@ WebHandler Language="C#" Class="GetPostCase" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using KaiValid;

public class GetPostCase : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        var taiwanCalendar = new System.Globalization.TaiwanCalendar();
        DataClassesDataContext DB = new DataClassesDataContext();
        ValidJson kaiValid = new ValidJson(context);
        string type = context.Items["type"].ToString();
        if (type.Equals("CaseListAll"))
        {
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           where a.EndDate == null
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString()),
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate == null
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate == null
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate == null
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate == null
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("CaseSearchAll"))
        {
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           join k in DB.CouncilorType on e.CouncilorTypeID equals k.CouncilorTypeID
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               a.ContactName,
                               a.ContactTel,
                               CouncilorNameType = k.Type,
                               EndDate = yearTr(a.EndDate.ToString()),
                               a.ExecuteContent,
                               a.State,
                               a.ZoneID,
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString())
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("WaitCase"))
        {
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           join k in DB.CouncilorType on e.CouncilorTypeID equals k.CouncilorTypeID
                           where a.EndDate == null
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               a.ContactName,
                               a.ContactTel,
                               CouncilorNameType = k.Type,
                               EndDate = yearTr(a.EndDate.ToString()),
                               a.ExecuteContent,
                               a.State,
                               a.ZoneID,
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString())
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate == null
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate == null
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate == null
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate == null
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));

        }
        else if (type.Equals("YearSearch"))
        {
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           join k in DB.CouncilorType on e.CouncilorTypeID equals k.CouncilorTypeID
                           where a.EndDate == null && a.State == "2"
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               a.ContactName,
                               a.ContactTel,
                               CouncilorNameType = k.Type,
                               EndDate = yearTr(a.EndDate.ToString()),
                               a.ExecuteContent,
                               a.State,
                               a.ZoneID,
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString())
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate == null && a.State == "2"
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate == null && a.State == "2"
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate == null && a.State == "2"
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate == null && a.State == "2"
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("OverDateSearch"))
        {

            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           join k in DB.CouncilorType on e.CouncilorTypeID equals k.CouncilorTypeID
                           where a.EndDate == null
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               a.ContactName,
                               a.ContactTel,
                               CouncilorNameType = k.Type,
                               EndDate = yearTr(a.EndDate.ToString()),
                               a.ExecuteContent,
                               a.State,
                               a.ZoneID,
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString())
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate == null
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate == null
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate == null
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate == null
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("EndSearch"))
        {
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           join k in DB.CouncilorType on e.CouncilorTypeID equals k.CouncilorTypeID
                           where a.EndDate != null
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               a.ContactName,
                               a.ContactTel,
                               CouncilorNameType = k.Type,
                               EndDate = yearTr(a.EndDate.ToString()),
                               a.ExecuteContent,
                               a.State,
                               a.ZoneID,
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString())
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate != null
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate != null
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate != null
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate != null
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("My"))
        {
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           where a.EndDate == null && a.CaseOfficerID == user.UserLoginID
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString()),
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate == null && a.CaseOfficerID == user.UserLoginID
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate == null && a.CaseOfficerID == user.UserLoginID
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate == null && a.CaseOfficerID == user.UserLoginID
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate == null && a.CaseOfficerID == user.UserLoginID
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("1"))
        {
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 1
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString()),
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 1
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 1
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 1
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 1
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("2"))
        {
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 2
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString()),
                           };
            var CouncilorName = (from a in DB.CaseBase
                                 join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                                 where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 2
                                 select e.Name).Distinct();
            var Zone = (from a in DB.CaseBase
                        join f in DB.Zone on a.ZoneID equals f.ZoneID
                        where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 2
                        select f.Name).Distinct();
            var CaseOfficer = (from a in DB.CaseBase
                               join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                               where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 2
                               select g.UserName).Distinct();
            var minDateR = (from a in DB.CaseBase
                            orderby a.SuggestDate
                            where a.EndDate == null && (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault() == 2
                            select new
                            {
                                SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate)
                            }).FirstOrDefault();
            string minDate = yearTr(DateTime.Now.ToString("yyyy-MM-dd"));
            if (minDateR != null)
            {
                minDate = minDateR.SuggestDate;
            }

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("CaseOfficer", CaseOfficer);
            result.Add("minDate", minDate);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("CaseBaseInster"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];

            string temp = json.suggestDate;
            temp = (Int32.Parse(temp.Split('-')[0]) + 1911) + "-" + temp.Split('-')[1] + "-" + temp.Split('-')[2];
            DateTime suggestDate = DateTime.Parse(temp);
            CaseBase st = new CaseBase
            {
                CouncilorNameID = Convert.ToInt32(json.Councilor.CouncilorNameID),
                ZoneID = Convert.ToInt32(json.Zone.ZoneID),
                CaseOfficerID = Convert.ToInt32(json.UserLogin.UserLoginID),
                ContactName = json.contactName,
                Address = json.address,
                SuggestContent = json.suggestContent,
                SuggestDate = suggestDate,
                ContactTel = json.contactTel,
                EmployeeID = Convert.ToInt32(user.UserLoginID),
                ModifiedDate = DateTime.Now,
                ExecuteContent = "",
                State = "1"
            };
            DB.CaseBase.InsertOnSubmit(st);
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
        }
        else if (type.Equals("EditCase"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            var CaseBase = (from a in DB.CaseBase
                            where a.State != "0" && a.CaseBaseID == Convert.ToInt32(strJson)
                            select new
                            {
                                a.CaseBaseID,
                                SuggestDate = yearTr(a.SuggestDate.ToString()),
                                CouncilorName = (from b in DB.CouncilorName
                                                 where a.CouncilorNameID == b.CouncilorNameID
                                                 select new
                                                 {
                                                     Name = (from c in DB.CouncilorType where b.CouncilorTypeID == c.CouncilorTypeID select c.Type).FirstOrDefault() + " ─ " + b.Name,
                                                     b.CouncilorNameID
                                                 }).FirstOrDefault(),
                                a.ContactName,
                                a.ContactTel,
                                CaseOfficer = (from b in DB.UserLogin
                                               where a.CaseOfficerID == b.UserLoginID
                                               select new
                                               {
                                                   b.UserName,
                                                   b.UserLoginID
                                               }).FirstOrDefault(),
                                Zone = (from b in DB.Zone
                                        where a.ZoneID == b.ZoneID
                                        select new
                                        {
                                            b.Name,
                                            b.ZoneID
                                        }).FirstOrDefault(),
                                a.Address,
                                a.State,
                                a.SuggestContent,
                                EndDate = yearTr(a.EndDate.ToString()),
                                a.ExecuteContent
                            }).FirstOrDefault();
            var CouncilorName = (from a in DB.CouncilorName
                                 where a.State != "0"
                                 select new
                                 {
                                     Name = (from c in DB.CouncilorType where a.CouncilorTypeID == c.CouncilorTypeID select c.Type).FirstOrDefault() + " ─ " + a.Name,
                                     a.CouncilorNameID
                                 });
            var Zone = (from a in DB.Zone
                        where a.State != "0"
                        select new
                        {
                            a.Name,
                            a.ZoneID
                        });
            var UserName = (from a in DB.UserLogin
                            where a.State != "0" && a.Officer == "1"
                            select new
                            {
                                a.UserName,
                                a.UserLoginID
                            });
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("CaseBase", CaseBase);
            result.Add("CouncilorName", CouncilorName);
            result.Add("Zone", Zone);
            result.Add("UserName", UserName);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("CaseBaseUpdate"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];

            int CaseBaseID = Convert.ToInt32(kaiValid.validNull(json.CaseBaseID));
            var update = (from a in DB.CaseBase
                          where a.CaseBaseID == CaseBaseID
                          select a).FirstOrDefault();

            update.Address = kaiValid.validNull(json.Address);
            update.CaseOfficerID = kaiValid.validNull(json.CaseOfficer.UserLoginID);
            update.ContactName = kaiValid.validNull(json.ContactName);
            update.ContactTel = kaiValid.validNull(json.ContactTel);
            update.CouncilorNameID = kaiValid.validNull(json.CouncilorName.CouncilorNameID);
            update.ZoneID = kaiValid.validNull(json.Zone.ZoneID);
            update.State = kaiValid.validNull(json.State);
            update.SuggestContent = kaiValid.validNull(json.SuggestContent);
            update.ExecuteContent = kaiValid.validNull(json.ExecuteContent);
            string temp3 = json.EndDate + "";
            if (user.Admin.Equals("1") || user.Admin.Equals("2"))
            {
                if (!temp3.Equals(""))
                {
                    string temp2 = kaiValid.validNull(json.EndDate);
                    temp2 = (Int32.Parse(temp2.Split('-')[0]) + 1911) + "-" + temp2.Split('-')[1] + "-" + temp2.Split('-')[2];
                    DateTime EndDate = DateTime.Parse(temp2);
                    update.EndDate = EndDate;
                }
            }
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
        }
        else if (type.Equals("CaseBaseDelete"))
        {
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            if (user.Admin.Equals("2"))
            {
                dynamic json = kaiValid.tranResToDynamic();
                int CaseBaseID = Convert.ToInt32(kaiValid.validNull(json.CaseBaseID));
                var delete = (from a in DB.CaseBase
                              where a.CaseBaseID == CaseBaseID
                              select a).FirstOrDefault();
                DB.CaseBase.DeleteOnSubmit(delete);
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("你沒有權限做此動作！");
            }
        }
        else if (type.Equals("MailToSend"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            int types = Convert.ToInt32(strJson);
            var result = from a in DB.CaseBase
                         where a.EndDate == null
                         orderby a.CaseOfficerID
                         select new
                         {
                             a.CaseBaseID,
                             SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                             a.SuggestContent,
                             CouncilorName = (from b in DB.CouncilorName where a.CouncilorNameID == b.CouncilorNameID select b.Name).FirstOrDefault(),
                             a.CouncilorNameID,
                             Zone = (from b in DB.Zone where a.ZoneID == b.ZoneID select b.Name).FirstOrDefault(),
                             a.ZoneID,
                             a.Address,
                             CaseOfficer = (from b in DB.UserLogin where a.CaseOfficerID == b.UserLoginID select b.UserName).FirstOrDefault(),
                             CaseOfficerEmail = (from b in DB.UserLogin where a.CaseOfficerID == b.UserLoginID select b.UserID).FirstOrDefault(),
                             OverDayInt = getOverDayInt(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString()),
                             OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString())
                         };
            if (types == 0)
            {
                string email = "";
                string mailBody = "";
                bool sendFlag = false;
                KaiNamespace.SendMail s = new KaiNamespace.SendMail();
                foreach (var temp in result)
                {
                    if (temp.OverDayInt > 0)
                    {
                        sendFlag = true;
                        string emailTemp = temp.CaseOfficer;
                        if (email.Equals(""))
                        {
                            email = emailTemp;
                            s.setSendName(temp.CaseOfficerEmail, temp.CaseOfficer);
                            mailBody = "<table border='1' style='border-collapse:collapse;border:1px solid #000000;color:#000000;width:100%' cellpadding='3' cellspacing='3'><tr><td style='width:60px;'>編號</td><td style='width:110px;'>建議時間</td><td style='width:70px;'>行政區</td><td style='width:250px;'>建議路口/段</td><td>建議事項</td><td style='width:80px;'>案件狀態</td></tr>";
                            mailBody = mailBody + "<tr><td>" + temp.CaseBaseID + "</td><td>" + temp.SuggestDate + "</td><td>" + temp.Zone + "</td><td>" + temp.Address + "</td><td>" + temp.SuggestContent + "</td><td>" + temp.OverDay + "</td></tr>";
                        }
                        else if (emailTemp.Equals(email))
                        {
                            mailBody = mailBody + "<tr><td>" + temp.CaseBaseID + "</td><td>" + temp.SuggestDate + "</td><td>" + temp.Zone + "</td><td>" + temp.Address + "</td><td>" + temp.SuggestContent + "</td><td>" + temp.OverDay + "</td></tr>";
                        }
                        else if (!emailTemp.Equals(email))
                        {
                            mailBody = mailBody + "</table>";
                            s.setMailBody(mailBody);
                            s.sendtoMail(types + "", mailBody);
                            s.clearSendName();
                            s.clearMailBody();
                            s.setSendName(temp.CaseOfficerEmail, temp.CaseOfficer);
                            mailBody = "<table border='1' style='border-collapse:collapse;border:1px solid #000000;color:#000000;width:100%' cellpadding='3' cellspacing='3'><tr><td style='width:60px;'>編號</td><td style='width:110px;'>建議時間</td><td style='width:70px;'>行政區</td><td style='width:250px;'>建議路口/段</td><td>建議事項</td><td style='width:80px;'>案件狀態</td></tr>";
                            mailBody = mailBody + "<tr><td>" + temp.CaseBaseID + "</td><td>" + temp.SuggestDate + "</td><td>" + temp.Zone + "</td><td>" + temp.Address + "</td><td>" + temp.SuggestContent + "</td><td>" + temp.OverDay + "</td></tr>";
                            email = emailTemp;
                        }
                    }
                }
                if (sendFlag)
                {
                    mailBody = mailBody + "</table>";
                    s.setMailBody(mailBody);
                }
                s.sendtoMail(types + "", mailBody);
                s.closeMail();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                string mailBody = "";
                bool sendFlag = false;
                KaiNamespace.SendMail s = new KaiNamespace.SendMail();
                var sendName = from a in DB.SendName
                               where a.Type == (types + "")
                               select new
                               {
                                   UserName = (from h in DB.UserLogin where h.UserLoginID == a.UserLoginID select h.UserName).FirstOrDefault(),
                                   email = (from h in DB.UserLogin where h.UserLoginID == a.UserLoginID select h.UserID).FirstOrDefault(),
                                   a.UserLoginID
                               };
                foreach (var temps in sendName)
                {
                    s.setSendName(temps.email, temps.UserName);
                }
                bool oneFlag = true;
                s.setSubject("逾期案件列表(" + types + "天)");
                foreach (var temp in result)
                {
                    if ((temp.OverDayInt + 3) > types)
                    {
                        sendFlag = true;
                        if (oneFlag)
                        {
                            mailBody = "<table border='1' style='border-collapse:collapse;border:1px solid #000000;color:#000000;width:100%' cellpadding='3' cellspacing='3'><tr><td style='width:60px;'>編號</td><td style='width:110px;'>建議時間</td><td style='width:70px;'>行政區</td><td style='width:250px;'>建議路口/段</td><td>建議事項</td><td style='width:80px;'>承辦人</td><td style='width:80px;'>案件狀態</td></tr>";
                            mailBody = mailBody + "<tr><td>" + temp.CaseBaseID + "</td><td>" + temp.SuggestDate + "</td><td>" + temp.Zone + "</td><td>" + temp.Address + "</td><td>" + temp.SuggestContent + "</td><td>" + temp.CaseOfficer + "</td><td>" + temp.OverDay + "</td></tr>";
                            oneFlag = false;
                        }
                        else
                        {
                            mailBody = mailBody + "<tr><td>" + temp.CaseBaseID + "</td><td>" + temp.SuggestDate + "</td><td>" + temp.Zone + "</td><td>" + temp.Address + "</td><td>" + temp.SuggestContent + "</td><td>" + temp.CaseOfficer + "</td><td>" + temp.OverDay + "</td></tr>";
                        }
                    }
                }
                if (sendFlag)
                {
                    mailBody = mailBody + "</table>";
                    s.setMailBody(mailBody);
                }
                s.sendtoMail(types + "", mailBody);
                s.closeMail();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
        }
        else if (type.Equals("Home"))
        {
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            DateTime nowDay = DateTime.Now;
            DateTime start = nowDay;
            DateTime end = nowDay;
            if ((int)nowDay.DayOfWeek == 0)
            {
                start = nowDay;
            }
            else if ((int)nowDay.DayOfWeek == 1)
            {
                start = nowDay.AddDays(-1);
            }
            else if ((int)nowDay.DayOfWeek == 2)
            {
                start = nowDay.AddDays(-2);
            }
            else if ((int)nowDay.DayOfWeek == 3)
            {
                start = nowDay.AddDays(-3);
            }
            else if ((int)nowDay.DayOfWeek == 4)
            {
                start = nowDay.AddDays(-4);
            }
            else if ((int)nowDay.DayOfWeek == 5)
            {
                start = nowDay.AddDays(-5);
            }
            else if ((int)nowDay.DayOfWeek == 6)
            {
                start = nowDay.AddDays(-6);
            }
            var allCaseBase = from a in DB.CaseBase
                              select new
                              {
                                  Unit = (from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault(),
                                  a.SuggestDate,
                                  a.EndDate,
                                  OverDay = getOverDayInt(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString()),
                                  a.State
                              };
            int allCase = 0;
            int endCase = 0;
            int nowCase = 0;
            int thisCase = 0;
            int yearCase = 0;
            int thisYearCase = 0;
            int overCase = 0;
            int thisOverCase = 0;
            int one = 0;
            int overOne = 0;
            int two = 0;
            int overTwo = 0;
            foreach (var temp in allCaseBase)
            {
                if (temp.EndDate == null)
                {
                    nowCase = nowCase + 1;
                    if (temp.SuggestDate >= start && temp.SuggestDate <= end)
                    {
                        thisCase = thisCase + 1;
                        if (temp.State == "2")
                        {
                            thisYearCase = thisYearCase + 1;
                        }
                    }
                    if (temp.OverDay > 0)
                    {
                        overCase = overCase + 1;
                        if (temp.Unit == 1)
                        {
                            overOne = overOne + 1;
                        }
                        if (temp.Unit == 2)
                        {
                            overTwo = overTwo + 1;
                        }
                    }
                    if (temp.OverDay < 8 && temp.OverDay > 0)
                    {
                        thisOverCase = thisOverCase + 1;
                    }
                    if (temp.Unit == 1)
                    {
                        one = one + 1;
                    }
                    if (temp.Unit == 2)
                    {
                        two = two + 1;
                    }
                    if (temp.State == "2")
                    {
                        yearCase = yearCase + 1;
                    }
                }
                else
                {
                    endCase = endCase + 1;
                }
                allCase = allCase + 1;
            }
            var CaseBase = from a in DB.CaseBase
                           join e in DB.CouncilorName on a.CouncilorNameID equals e.CouncilorNameID
                           join f in DB.Zone on a.ZoneID equals f.ZoneID
                           join g in DB.UserLogin on a.CaseOfficerID equals g.UserLoginID
                           where a.EndDate == null
                           orderby a.CaseBaseID descending
                           select new
                           {
                               a.CaseBaseID,
                               SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                               a.SuggestContent,
                               CouncilorName = new
                               {
                                   e.Name,
                                   e.CouncilorNameID
                               },
                               Zone = new
                               {
                                   f.Name,
                                   f.ZoneID
                               },
                               a.Address,
                               CaseOfficer = new
                               {
                                   g.UserName,
                                   g.UserLoginID
                               },
                               OverDay = getOverDay(a.State, a.ExecuteContent, a.SuggestDate, a.EndDate.ToString()),
                           };
            result.Add("allCase", allCase);
            result.Add("endCase", endCase);
            result.Add("nowCase", nowCase);
            result.Add("thisCase", thisCase);
            result.Add("overCase", overCase);
            result.Add("thisOverCase", thisOverCase);
            result.Add("yearCase", yearCase);
            result.Add("thisYearCase", thisYearCase);
            result.Add("one", one);
            result.Add("overOne", overOne);
            result.Add("two", two);
            result.Add("overTwo", overTwo);
            result.Add("CaseBase", CaseBase);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else
        {
            var result = from a in DB.CaseBase
                         where a.State != "0"
                         select a;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
    }

    public string yearTr(string a)
    {
        if (a == null)
        {
            return "";
        }
        else
        {
            DateTime s = DateTime.Parse(a);
            return string.Format("{0}-{1:MM-dd}", s.Year - 1911, s);
        }
    }

    public string getOverDay(string state, string executeContent, DateTime suggestDate, string edDate)
    {
        if (edDate == null)
        {
            //一般案件
            if (state.Equals("1"))
            {
                string executeContentT = executeContent + "";
                int days = 0;
                DateTime nowDay = DateTime.Now;
                DateTime startDay = suggestDate;
                while (startDay < nowDay)
                {
                    if ((int)startDay.DayOfWeek != 0 && (int)startDay.DayOfWeek != 6)
                    {
                        days = days + 1;
                    }
                    startDay = startDay.AddDays(1);
                }
                //如果沒輸入辦理情況
                if (executeContentT.Equals(""))
                {
                    if (days > 4)
                    {
                        return "逾期 " + (days - 4) + " 天";
                    }
                    else
                    {
                        return "";
                    }
                }
                else
                {
                    if (days > 22)
                    {
                        return "逾期 " + (days - 22) + " 天";
                    }
                    else
                    {
                        return "";
                    }
                }
            }
            else
            {
                return "年度計劃";
            }
        }
        else
        {
            return "除管";
        }
    }
    public int getOverDayInt(string state, string executeContent, DateTime suggestDate, string edDate)
    {
        if (edDate == null)
        {
            //一般案件
            if (state.Equals("1"))
            {
                string executeContentT = executeContent + "";
                int days = 0;
                DateTime nowDay = DateTime.Now;
                DateTime startDay = suggestDate;
                while (startDay < nowDay)
                {
                    if ((int)startDay.DayOfWeek != 0 && (int)startDay.DayOfWeek != 6)
                    {
                        days = days + 1;
                    }
                    startDay = startDay.AddDays(1);
                }
                //如果沒輸入辦理情況
                if (executeContentT.Equals(""))
                {
                    if (days > 4)
                    {
                        return (days - 4);
                    }
                    else
                    {
                        return 0;
                    }
                }
                else
                {
                    if (days > 22)
                    {
                        return (days - 22);
                    }
                    else
                    {
                        return 0;
                    }
                }
            }
            else
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }


    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}