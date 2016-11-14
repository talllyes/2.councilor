<%@ WebHandler Language="C#" Class="GetPostItem" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;

public class GetPostItem : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        string type = context.Items["type"].ToString();
        if (type.Equals("CouncilorName"))
        {
            var result = from a in DB.CouncilorName
                         where a.State != "0"
                         orderby a.CouncilorNameOrder
                         select new
                         {
                             a.Name,
                             CouncilorType = (from b in DB.CouncilorType where a.CouncilorTypeID == b.CouncilorTypeID select b.Type).FirstOrDefault(),
                             a.CouncilorNameID
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("Zone"))
        {
            var result = from a in DB.Zone
                         where a.State != "0"
                         orderby a.ZoneOrder
                         select new
                         {
                             a.Name,
                             a.ZoneID
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("UserName"))
        {
            var result = from a in DB.UserLogin
                         where a.State != "0"
                         orderby a.UserOrder
                         select new
                         {
                             a.UserName,
                             a.UserLoginID
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("NewCaseItem"))
        {
            var result = (from all in DB.CouncilorName
                          select new
                          {
                              CouncilorName = (from a in DB.CouncilorName
                                               where a.State != "0"
                                               orderby a.CouncilorNameOrder
                                               select new
                                               {
                                                   Name = (from b in DB.CouncilorType where a.CouncilorTypeID == b.CouncilorTypeID select b.Type).FirstOrDefault() + " ─ " + a.Name,
                                                   CouncilorType = (from b in DB.CouncilorType where a.CouncilorTypeID == b.CouncilorTypeID select b.Type).FirstOrDefault(),
                                                   a.CouncilorNameID
                                               }),
                              Zone = (from a in DB.Zone
                                      where a.State != "0"
                                      orderby a.ZoneOrder
                                      select new
                                      {
                                          a.Name,
                                          a.ZoneID
                                      }),
                              UserName = (from a in DB.UserLogin
                                          where a.State != "0" && a.Officer == "1"
                                          orderby a.UserOrder
                                          select new
                                          {
                                              a.UserName,
                                              a.UserLoginID
                                          })
                          }).FirstOrDefault();
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

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}