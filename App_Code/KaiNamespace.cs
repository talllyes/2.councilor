using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Compilation;
using System.Web.Hosting;
using System.Web.Routing;

/// <summary>
/// KaiNamespace 的摘要描述
/// </summary>

namespace KaiNamespace
{
    public class ApiRoute : IRouteHandler
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            var routeData = requestContext.RouteData;
            //取出參數
            string model = Convert.ToString(routeData.Values["model"]);
            string type = Convert.ToString(routeData.Values["type"]);
            HttpContext.Current.Items.Add("model", model);
            if (!string.IsNullOrEmpty(type))
                HttpContext.Current.Items.Add("type", type);
            //檢查看看有無該Model對應的ASHX?
            string ashxName = model + ".ashx";
            //找不到對應的ASHX
            if (!File.Exists(HostingEnvironment.MapPath("~/api/" + ashxName)))
                return BuildManager.CreateInstanceFromVirtualPath("~/api/error.ashx",
                typeof(IHttpHandler)) as IHttpHandler;
            //導向指定的ASHX
            return BuildManager.CreateInstanceFromVirtualPath("~/api/" + ashxName,
                typeof(IHttpHandler)) as IHttpHandler;
        }
    }
    public class HtmlRoute : IRouteHandler
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            string url = HttpContext.Current.Request.RawUrl;
            if (url.IndexOf("/index") != -1)
            {
                return BuildManager.CreateInstanceFromVirtualPath("~/index.html", typeof(IHttpHandler)) as IHttpHandler;
            }
            else
            {
                return BuildManager.CreateInstanceFromVirtualPath("~/login.html", typeof(IHttpHandler)) as IHttpHandler;
            }
        }
    }
    public class IdentityAuthority : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            string logoutUrl = System.IO.Path.GetFileName(context.Request.PhysicalPath);
            if (logoutUrl.Equals("login.html") || logoutUrl.Equals("index.html"))
            {
                context.Response.Redirect("~/login");
            }
            else
            {
                if (context.Session["councilorLogin"] == null)
                {
                    context.Response.Redirect("~/login");
                }
                else if (logoutUrl.IndexOf("Manager") != -1)
                {
                    KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
                    user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
                    if (user.Admin.Equals("1") || user.Admin.Equals("2"))
                    {
                        var handler = BuildManager.CreateInstanceFromVirtualPath(context.Request.Path, typeof(IHttpHandler)) as IHttpHandler;
                        context.Server.Transfer(handler, false);
                    }
                }
                else
                {
                    var handler = BuildManager.CreateInstanceFromVirtualPath(context.Request.Path, typeof(IHttpHandler)) as IHttpHandler;
                    context.Server.Transfer(handler, false);
                    // context.Response.WriteFile(context.Request.PhysicalPath);
                }
            }
        }
        public bool IsReusable
        {
            get
            {
                return true;
            }
        }
    }
    public class NotEnter : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.Redirect("~/login");
        }
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
    public class SendMail
    {
        SmtpClient smtpServer;
        MailMessage sendMail;
        DataClassesDataContext DB;
        string sendTo = "";
        public SendMail()
        {
            DB = new DataClassesDataContext();
            var result = (from a in DB.MailConfig select a).FirstOrDefault();
            sendMail = new MailMessage();
            sendMail.From = new MailAddress(result.MailName, result.SendName);
            sendMail.Priority = MailPriority.Normal;  //優先等級
            sendMail.Subject = result.Subject;
            sendMail.IsBodyHtml = true;  // 設定Email 內容為HTML格式
            sendMail.BodyEncoding = System.Text.Encoding.UTF8;
            smtpServer = new SmtpClient();
            smtpServer.Host = result.Smtp;
            smtpServer.Port = (int)result.Port;
            if (result.MailName.IndexOf("gmail") != -1)
            {
                smtpServer.UseDefaultCredentials = true;
                smtpServer.EnableSsl = true;
                smtpServer.DeliveryMethod = SmtpDeliveryMethod.Network;
            }
            smtpServer.Credentials = new System.Net.NetworkCredential(result.MailID, result.Password);
        }

        public void clearSendName()
        {
            sendMail.To.Clear();
            sendTo = "";
        }
        public void setSubject(string subject)
        {
            sendMail.Subject = subject;
        }
        public void setSendName(string id, string name)
        {
            sendMail.To.Add(new MailAddress(id, name));
            sendTo = sendTo + id + "(" + name + "),";
        }
        public void clearMailBody()
        {
            sendMail.Body = "";
        }
        public void setMailBody(string body)
        {
            sendMail.Body = sendMail.Body + body;
        }
        public void sendtoMail(string type, string body)
        {
            string message = "";
            try
            {
                smtpServer.Send(sendMail);
                message = "寄信成功！";
            }
            catch (Exception e)
            {
                message = "寄信失敗：" + e;
            }
            MailLog st = new MailLog
            {
                Type = type,
                SendContent = body,
                SendTo = sendTo,
                SendMessage = message,
                SendDate = DateTime.Now
            };
            DB.MailLog.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        public void closeMail()
        {
            try
            {
                sendMail.Dispose();
                smtpServer.Dispose();
            }
            catch (Exception)
            {

            }
        }
    }

    public class LoginSession
    {
        public int UserLoginID;
        public string UserID;
        public string UserName;
        public int JobTitleID;
        public string State;
        public string Admin;
    }
}
