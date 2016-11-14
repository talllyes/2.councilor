<%@ WebHandler Language="C#" Class="login" %>

using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;
using System.Security.Cryptography;
using System.Text;

public class login : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        DataClasses2DataContext DB2 = new DataClasses2DataContext();
        string type = context.Items["type"].ToString();

        if (type.Equals("login"))
        {
            string id = context.Request.Form["id"].ToString();
            string password = context.Request.Form["password"].ToString();

            SHA256 sha256 = new SHA256CryptoServiceProvider();
            byte[] source = Encoding.Default.GetBytes(password);
            byte[] crypto = sha256.ComputeHash(source);
            password = Convert.ToBase64String(crypto);


            var result = (from s in DB.UserLogin
                          where s.UserID == id && s.Password == password && s.State == "1"
                          select s).FirstOrDefault();
            if (result != null)
            {
                KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
                user.UserID = result.UserID;
                user.UserLoginID = result.UserLoginID;
                user.UserName = result.UserName;
                user.JobTitleID = (int)result.JobTitleID;
                user.State = result.State;
                user.Admin = result.Admin;
                loginNum st = new loginNum
                {
                    LoginDate = DateTime.Now,
                    SystemType = "2",
                    LoginID = user.UserID
                };
                DB2.loginNum.InsertOnSubmit(st);
                DB2.SubmitChanges();
                context.Session["councilorLogin"] = user;
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Session.Clear();
                context.Response.ContentType = "text/plain";
                context.Response.Write("no");
            }
        }
        else if (type.Equals("logout"))
        {
            context.Session.Clear();
        }
        else if (type.Equals("check"))
        {
            if (context.Session["councilorLogin"] == null)
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("no");
            }
            else
            {
                KaiNamespace.LoginSession user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
                var result = (from s in DB.UserLogin
                              where s.UserLoginID == user.UserLoginID
                              select s).FirstOrDefault();

                user.UserID = result.UserID;
                user.UserLoginID = result.UserLoginID;
                user.UserName = result.UserName;
                user.JobTitleID = (int)result.JobTitleID;
                user.State = result.State;
                user.Admin = result.Admin;
                context.Session["councilorLogin"] = user;
                context.Response.ContentType = "text/plain";
                context.Response.Write(JsonConvert.SerializeObject(result));
            }
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("Not Found!!");
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