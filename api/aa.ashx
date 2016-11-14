<%@ WebHandler Language="C#" Class="GetPostItem" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;
using System.IO;

public class GetPostItem : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        string type = context.Items["type"].ToString();
        if (type.Equals("aa"))
        {


            using (StreamReader SR = new StreamReader(context.Request.PhysicalApplicationPath + "Book1.csv"))
            {
                string Line;
                while ((Line = SR.ReadLine()) != null)
                {
                    string[] dd = Line.Split(',');
                    if (dd.Count() > 5)
                    {
                        var ss = (from a in DB.CouncilorName
                                  where a.Name == dd[0]
                                  select a.CouncilorNameID).FirstOrDefault();
                        var zz = (from a in DB.Zone
                                  where a.Name == dd[1]
                                  select a.ZoneID).FirstOrDefault();
                        var cc = (from a in DB.UserLogin
                                  where a.UserName == dd[2]
                                  select a.UserLoginID).FirstOrDefault();

                        string yyyy = dd[5].Split('/')[0];
                        string mm = dd[5].Split('/')[1];
                        string ddd = dd[5].Split('/')[2];

                        if (mm.Length == 1)
                        {
                            mm = "0" + mm;
                        }
                        if (ddd.Length == 1)
                        {
                            ddd = "0" + ddd;
                        }



                        CaseBase aaa = new CaseBase()
                        {
                            CouncilorNameID = ss,
                            ZoneID = zz,
                            CaseOfficerID = cc,
                            Address = dd[3],
                            SuggestContent = dd[4],
                            SuggestDate = DateTime.ParseExact(yyyy + mm + ddd, "yyyyMMdd", null, System.Globalization.DateTimeStyles.AllowWhiteSpaces),
                            ExecuteContent = dd[6],
                            State = "1",
                            ContactTel = "",
                            ContactName = "",
                            EmployeeID = 0,
                            ModifiedDate=DateTime.Now
                        };
                        DB.CaseBase.InsertOnSubmit(aaa);

                    }
                }
                DB.SubmitChanges();
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");

        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("??");

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