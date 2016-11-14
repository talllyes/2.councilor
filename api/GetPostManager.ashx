<%@ WebHandler Language="C#" Class="GetPostManager" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using KaiValid;

public class GetPostManager : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {

        DataClassesDataContext DB = new DataClassesDataContext();
        ValidJson kaiValid = new ValidJson(context);
        string type = context.Items["type"].ToString();
        if (type.Equals("UserList"))
        {
            #region 取得使用者列表
            var UserList = from a in DB.UserLogin
                           orderby a.UserOrder
                           select new
                           {
                               a.UserLoginID,
                               a.UserID,
                               a.UserName,
                               a.UserOrder,
                               JobTitle = (from k in DB.JobTitle
                                           where a.JobTitleID == k.JobTitleID
                                           select new
                                           {
                                               k.JobTitleID,
                                               k.Name
                                           }).FirstOrDefault(),
                               State = (from k in DB.UserLogin
                                        where a.UserLoginID == k.UserLoginID
                                        select new
                                        {
                                            k.State,
                                            Name = (k.State == "0" ? "停用" : "啟用")
                                        }).FirstOrDefault(),
                               Unit = (from k in DB.UserLogin
                                       where a.Unit == k.Unit
                                       select new
                                       {
                                           Unit = k.Unit + "",
                                           Name = (k.Unit == 1 ? "號誌股" : "交控股")
                                       }).FirstOrDefault(),
                               Admin = (from k in DB.UserLogin
                                        where a.UserLoginID == k.UserLoginID
                                        select new
                                        {
                                            k.Admin,
                                            Name = getAdmin(k.Admin)
                                        }).FirstOrDefault(),
                               Officer = (from k in DB.UserLogin
                                          where a.UserLoginID == k.UserLoginID
                                          select new
                                          {
                                              k.Officer,
                                              Name = (k.Officer == "0" ? "否" : "是")
                                          }).FirstOrDefault(),
                               HaveCase = ((from g in DB.searchCase where g.UserLoginID == a.UserLoginID select g.CaseBase).FirstOrDefault() == null ? true : false)
                           };
            var JobTitle = from k in DB.JobTitle
                           select new
                           {
                               k.JobTitleID,
                               k.Name
                           };
            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();
            result.Add("UserList", UserList);
            result.Add("JobTitle", JobTitle);
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
            #endregion
        }
        else if (type.Equals("MailLog"))
        {
            var result = from a in DB.MailLog
                         orderby a.SendDate descending
                         select new
                         {
                             a.MailLogID,
                             a.SendContent,
                             a.SendMessage,
                             a.Type,
                             a.SendTo,
                             SendDate = string.Format("{0:yyyy-MM-dd HH:mm:ss}", a.SendDate)
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("SendList"))
        {
            #region 取得寄信列表
            var days = from f in DB.SendName where f.Type == "0" select f.UserLoginID;
            List<dynamic> NoSend = new List<dynamic>();
            foreach (var temp in days)
            {
                var b = (from a in DB.UserLogin
                         where !(from f in DB.SendName
                                 where type == "0" && f.Type == (temp.Value).ToString()
                                 select f.UserLoginID).Contains(a.UserLoginID) && a.State != "0"

                         orderby a.UserOrder
                         select new
                         {
                             a.UserName,
                             a.UserLoginID
                         });
                NoSend.Add(b);
            }
            List<dynamic> YesSend = new List<dynamic>();
            foreach (var temp in days)
            {
                var b = (from a in DB.SendName
                         where a.Type == (temp.Value).ToString()
                         select new
                         {
                             UserName = (from h in DB.UserLogin where h.UserLoginID == a.UserLoginID select h.UserName),
                             a.UserLoginID
                         });
                YesSend.Add(b);
            }
            Dictionary<string, List<dynamic>> result = new Dictionary<string, List<dynamic>>();
            result.Add("NoSend", NoSend);
            result.Add("YesSend", YesSend);

            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
            #endregion
        }
        else if (type.Equals("MailConfig"))
        {
            #region 取得寄信設定檔
            var mailConfig = (from a in DB.MailConfig
                              select new
                              {
                                  a.MailConfigID,
                                  a.MailID,
                                  a.MailName,
                                  a.Port,
                                  a.SendName,
                                  a.Smtp,
                                  a.Subject
                              }).FirstOrDefault();
            var days = from f in DB.SendName where f.Type == "0" select f.UserLoginID;
            List<dynamic> NoSend = new List<dynamic>();
            foreach (var temp in days)
            {
                var b = (from a in DB.UserLogin
                         where !(from f in DB.SendName
                                 where f.Type == (temp.Value).ToString()
                                 select f.UserLoginID).Contains(a.UserLoginID) && a.State != "0"
                         orderby a.UserOrder
                         select new
                         {
                             a.UserName,
                             a.UserLoginID,
                             Type = (temp.Value).ToString()
                         });
                NoSend.Add(b);
            }
            List<dynamic> YesSend = new List<dynamic>();
            foreach (var temp in days)
            {
                var b = (from a in DB.SendName
                         where a.Type == (temp.Value).ToString()
                         select new
                         {
                             UserName = (from h in DB.UserLogin where h.UserLoginID == a.UserLoginID select h.UserName).FirstOrDefault(),
                             a.UserLoginID,
                             Type = (temp.Value).ToString()
                         });
                YesSend.Add(b);
            }
            Dictionary<string, List<dynamic>> send = new Dictionary<string, List<dynamic>>();

            send.Add("NoSend", NoSend);
            send.Add("YesSend", YesSend);

            Dictionary<string, dynamic> result = new Dictionary<string, dynamic>();

            result.Add("Send", send);
            result.Add("MailConfig", mailConfig);


            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));


            #endregion
        }
        else if (type.Equals("UpdateMailConfig"))
        {
            #region 更新寄信設定檔
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            int MailConfigID = json.MailConfigID;
            var update = (from a in DB.MailConfig where a.MailConfigID == MailConfigID select a).FirstOrDefault();
            update.MailID = json.MailID;
            update.MailName = json.MailName;
            update.SendName = json.SendName;
            update.Port = json.Port;
            update.Smtp = json.Smtp;
            update.Subject = json.Subject;
            string password = json.Password + "";
            if (!password.Equals(""))
            {
                update.Password = password;
            }
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(update));
            #endregion
        }
        else if (type.Equals("UpdateSendName"))
        {
            #region 新增寄信對象
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            string Type = json[0].Type;
            var delete = from h in DB.SendName where h.Type != "0" && h.Type == Type select h;
            DB.SendName.DeleteAllOnSubmit(delete);
            DB.SubmitChanges();
            foreach (var temp in json)
            {
                SendName st = new SendName
                {
                    UserLoginID = temp.UserLoginID,
                    Type = temp.Type
                };
                DB.SendName.InsertOnSubmit(st);
            }
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
            #endregion
        }
        else if (type.Equals("UpdateSendNameNull"))
        {
            #region ??寄信對象
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            var delete = from h in DB.SendName where h.Type != "0" && h.Type == strJson select h;
            DB.SendName.DeleteAllOnSubmit(delete);
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
            #endregion
        }
        else if (type.Equals("DeleteSendName"))
        {
            #region 刪除寄信對象
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            string Type = json[0].Type;
            var delete = from h in DB.SendName where h.Type != "0" && h.Type == Type select h;
            DB.SendName.DeleteAllOnSubmit(delete);
            DB.SubmitChanges();
            foreach (var temp in json)
            {
                SendName st = new SendName
                {
                    UserLoginID = temp.UserLoginID,
                    Type = temp.Type
                };
                DB.SendName.InsertOnSubmit(st);
            }
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
            #endregion
        }
        else if (type.Equals("PostAddUser"))
        {
            #region 新增使用者
            dynamic json = kaiValid.tranResToDynamic();
            string UserID = kaiValid.validNull(json.UserID);
            var result = (from a in DB.UserLogin
                          where a.UserID == UserID
                          select a).FirstOrDefault();
            if (result == null)
            {
                var update = from b in DB.UserLogin
                             select b;
                foreach (var temp in update)
                {
                    temp.UserOrder = temp.UserOrder + 1;
                }
                DB.SubmitChanges();
                string password = kaiValid.validNull(json.Password) + "";
                string codePassword = "";
                SHA256 sha256 = new SHA256CryptoServiceProvider();
                byte[] source = Encoding.Default.GetBytes(password);
                byte[] crypto = sha256.ComputeHash(source);
                codePassword = Convert.ToBase64String(crypto);
                UserLogin st = new UserLogin
                {
                    UserName = kaiValid.validNull(json.UserName),
                    UserID = kaiValid.validNull(json.UserID),
                    Password = codePassword,
                    JobTitleID = kaiValid.validNull(json.JobTitle),
                    Unit = Convert.ToInt32(kaiValid.validNull(json.Unit)),
                    State = "1",
                    Admin = kaiValid.validNull(json.Admin),
                    UserOrder = 1,
                    Officer = kaiValid.validNull(json.Officer),
                    ModifiedDate = DateTime.Now
                };
                DB.UserLogin.InsertOnSubmit(st);
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已有相同帳號存在！");
            }
            #endregion
        }
        else if (type.Equals("EasyUpdateUser"))
        {
            #region 簡單版使用者更新
            context.Response.ContentType = "text/plain";
            dynamic json = kaiValid.tranResToDynamic();
            int UserLoginID = kaiValid.validNull(json.UserLoginID);
            var update = (from c in DB.UserLogin
                          where c.UserLoginID == UserLoginID
                          select c).FirstOrDefault();
            string password = kaiValid.validNull(json.Password) + "";
            string codePassword = "";
            if (!password.Equals(""))
            {
                SHA256 sha256 = new SHA256CryptoServiceProvider();
                byte[] source = Encoding.Default.GetBytes(password);
                byte[] crypto = sha256.ComputeHash(source);
                codePassword = Convert.ToBase64String(crypto);
                update.Password = codePassword;
            }
            update.UserName = kaiValid.validNull(json.UserName);
            update.UserID = kaiValid.validNull(json.UserID);
            update.JobTitleID = kaiValid.validNull(json.JobTitle.JobTitleID);
            update.Unit = Convert.ToInt32(kaiValid.validNull(json.Unit.Unit));
            update.State = kaiValid.validNull(json.State.State);
            update.Admin = kaiValid.validNull(json.Admin.Admin);
            update.Officer = kaiValid.validNull(json.Officer.Officer);
            update.ModifiedDate = DateTime.Now;
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
            #endregion
        }
        else if (type.Equals("UpdateUser"))
        {
            #region 更新使用者資料
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            int UserLoginID = json.UserLoginID;
            int UserOrder = json.UserOrder;
            if (UserOrder != 0)
            {
                int UserOrderBefore = json.UserOrderBefore;
                if (UserOrder > UserOrderBefore)
                {
                    var updateOrder = from x in DB.UserLogin
                                      where x.UserOrder <= UserOrder && x.UserOrder >= UserOrderBefore
                                      select x;
                    foreach (var temp in updateOrder)
                    {
                        temp.UserOrder = temp.UserOrder - 1;
                    }
                    DB.SubmitChanges();
                }
                else if (UserOrder < UserOrderBefore)
                {
                    var updateOrder = from x in DB.UserLogin
                                      where x.UserOrder >= UserOrder && x.UserOrder <= UserOrderBefore
                                      select x;
                    foreach (var temp in updateOrder)
                    {
                        temp.UserOrder = temp.UserOrder + 1;
                    }
                    DB.SubmitChanges();
                }
            }
            var update = (from c in DB.UserLogin
                          where c.UserLoginID == UserLoginID
                          select c).FirstOrDefault();
            string password = json.Password + "";
            string codePassword = "";
            if (!password.Equals(""))
            {
                SHA256 sha256 = new SHA256CryptoServiceProvider();
                byte[] source = Encoding.Default.GetBytes(password);
                byte[] crypto = sha256.ComputeHash(source);
                codePassword = Convert.ToBase64String(crypto);
                update.Password = codePassword;
            }
            if (UserOrder != 0)
            {
                update.UserOrder = UserOrder;
            }
            update.UserName = json.UserName;
            update.UserID = json.UserID;
            update.JobTitleID = json.JobTitle.JobTitleID;
            update.Unit = Convert.ToInt32(json.Unit.Unit);
            update.State = json.State.State;
            update.Admin = json.Admin.Admin;
            update.ModifiedDate = DateTime.Now;
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
            #endregion
        }
        else if (type.Equals("UserName"))
        {
            #region ???
            var result = from a in DB.UserLogin
                         where a.State != "0"
                         select new
                         {
                             a.UserName,
                             a.UserLoginID
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
            #endregion
        }
        else if (type.Equals("NewCaseItem"))
        {
            #region ???
            var result = (from all in DB.CouncilorName
                          select new
                          {
                              CouncilorName = (from a in DB.CouncilorName
                                               where a.State != "0"
                                               select new
                                               {
                                                   a.Name,
                                                   CouncilorType = (from b in DB.CouncilorType where a.CouncilorTypeID == b.CouncilorTypeID select b.Type).FirstOrDefault(),
                                                   a.CouncilorNameID
                                               }),
                              Zone = (from a in DB.Zone
                                      where a.State != "0"
                                      select new
                                      {
                                          a.Name,
                                          a.ZoneID
                                      }),
                              UserName = (from a in DB.UserLogin
                                          where a.State != "0"
                                          select new
                                          {
                                              a.UserName,
                                              a.UserLoginID
                                          })
                          }).FirstOrDefault();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
            #endregion
        }
        else if (type.Equals("CouncilorList"))
        {
            #region 取得議員列表
            var result = from a in DB.CouncilorName
                         orderby a.CouncilorNameOrder
                         select new
                         {
                             a.CouncilorNameID,
                             CouncilorTypeID = a.CouncilorTypeID + "",
                             CouncilorType = (from c in DB.CouncilorType where a.CouncilorTypeID == c.CouncilorTypeID select c.Type).FirstOrDefault(),
                             a.Name,
                             State = (from k in DB.CouncilorName
                                      where a.CouncilorNameID == k.CouncilorNameID
                                      select new
                                      {
                                          k.State,
                                          Name = (k.State == "0" ? "停用" : "啟用")
                                      }).FirstOrDefault(),
                             a.CouncilorNameOrder,
                             HaveCase = ((from g in DB.searchCouncilorName where g.CouncilorNameID == a.CouncilorNameID select g.CouncilorName).FirstOrDefault() == null ? true : false)
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
            #endregion
        }
        else if (type.Equals("JobTitleList"))
        {
            var result = from a in DB.JobTitle
                         orderby a.JobTitleOrder
                         select new
                         {
                             a.JobTitleID,
                             a.Name,
                             State = (from k in DB.JobTitle
                                      where a.JobTitleID == k.JobTitleID
                                      select new
                                      {
                                          k.State,
                                          Name = (k.State == "0" ? "停用" : "啟用")
                                      }).FirstOrDefault(),
                             a.JobTitleOrder
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("AddJobTitle"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            string Name = kaiValid.validNull(json.Name);
            var result = (from a in DB.JobTitle
                          where a.Name == Name
                          select a).FirstOrDefault();
            if (result == null)
            {
                var order = (from b in DB.JobTitle
                             orderby b.JobTitleOrder descending
                             select b).FirstOrDefault();

                JobTitle st = new JobTitle
                {
                    Name = json.Name,
                    State = "1",
                    JobTitleOrder = order.JobTitleOrder + 1
                };
                DB.JobTitle.InsertOnSubmit(st);
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已有相同職稱存在！");
            }
        }
        else if (type.Equals("EasyUpdateJobTitle"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            string Name = kaiValid.validNull(json.Name);
            int JobTitleID = kaiValid.validNull(json.JobTitleID);
            var result = (from a in DB.JobTitle
                          where a.Name == Name && a.JobTitleID != JobTitleID
                          select a).FirstOrDefault();
            if (result == null)
            {
                var update = (from c in DB.JobTitle
                              where c.JobTitleID == JobTitleID
                              select c).FirstOrDefault();
                update.State = kaiValid.validNull(json.State.State);
                update.Name = json.Name;
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已有相同職稱存在！");
            }
        }
        else if (type.Equals("AddCouncilor"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            string Name = kaiValid.validNull(json.Name);
            int CouncilorTypeID = kaiValid.validNull(json.CouncilorTypeID);
            var result = (from a in DB.CouncilorName
                          where a.Name == Name && a.CouncilorTypeID == CouncilorTypeID
                          select a).FirstOrDefault();
            if (result == null)
            {
                var update = from b in DB.CouncilorName
                             select b;
                foreach (var temp in update)
                {
                    temp.CouncilorNameOrder = temp.CouncilorNameOrder + 1;
                }
                DB.SubmitChanges();

                CouncilorName st = new CouncilorName
                {
                    Name = json.Name,
                    CouncilorTypeID = json.CouncilorTypeID,
                    State = kaiValid.validNull(json.State),
                    CouncilorNameOrder = 1
                };
                DB.CouncilorName.InsertOnSubmit(st);
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");

            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已有相同民代姓名存在！");
            }
        }
        else if (type.Equals("EasyUpdateCouncilor"))
        {
            dynamic json = kaiValid.tranResToDynamic();
            string Name = kaiValid.validNull(json.Name);
            int CouncilorNameID = kaiValid.validNull(json.CouncilorNameID);
            int CouncilorTypeID = kaiValid.validNull(json.CouncilorTypeID);
            var result = (from a in DB.CouncilorName
                          where a.Name == Name && a.CouncilorTypeID == CouncilorTypeID && a.CouncilorNameID != CouncilorNameID
                          select a).FirstOrDefault();
            if (result == null)
            {
                var update = (from c in DB.CouncilorName
                              where c.CouncilorNameID == CouncilorNameID
                              select c).FirstOrDefault();
                update.CouncilorTypeID = json.CouncilorTypeID;
                update.State = kaiValid.validNull(json.State.State);
                update.Name = json.Name;
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已有相同民代存在！");
            }
        }
        else if (type.Equals("UpdateCouncilor"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            int CouncilorNameID = json.CouncilorNameID;
            int CouncilorNameOrder = json.CouncilorNameOrder;
            int CouncilorTypeID = json.CouncilorTypeID;
            string Name = json.Name;
            var result = (from a in DB.CouncilorName
                          where a.Name == Name && a.CouncilorTypeID == CouncilorTypeID && a.CouncilorNameID != CouncilorNameID
                          select a).FirstOrDefault();
            if (result == null)
            {
                if (CouncilorNameOrder != 0)
                {
                    int CouncilorNameOrderBefore = json.CouncilorNameOrderBefore;
                    if (CouncilorNameOrder > CouncilorNameOrderBefore)
                    {
                        var updateOrder = from x in DB.CouncilorName
                                          where x.CouncilorNameOrder <= CouncilorNameOrder && x.CouncilorNameOrder >= CouncilorNameOrderBefore
                                          select x;
                        foreach (var temp in updateOrder)
                        {
                            temp.CouncilorNameOrder = temp.CouncilorNameOrder - 1;
                        }
                        DB.SubmitChanges();
                    }
                    else if (CouncilorNameOrder < CouncilorNameOrderBefore)
                    {
                        var updateOrder = from x in DB.CouncilorName
                                          where x.CouncilorNameOrder >= CouncilorNameOrder && x.CouncilorNameOrder <= CouncilorNameOrderBefore
                                          select x;
                        foreach (var temp in updateOrder)
                        {
                            temp.CouncilorNameOrder = temp.CouncilorNameOrder + 1;
                        }
                        DB.SubmitChanges();
                    }
                }
                var update = (from c in DB.CouncilorName
                              where c.CouncilorNameID == CouncilorNameID
                              select c).FirstOrDefault();

                if (CouncilorNameOrder != 0)
                {
                    update.CouncilorNameOrder = CouncilorNameOrder;
                }
                update.CouncilorTypeID = json.CouncilorTypeID;
                update.State = json.State.State;
                update.Name = json.Name;
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已存在相同人名");
            }
        }
        else if (type.Equals("ZoneList"))
        {
            var result = from a in DB.Zone
                         orderby a.ZoneOrder
                         select new
                         {
                             a.ZoneID,
                             a.ZoneOrder,
                             a.Name,
                             State = (from k in DB.Zone
                                      where a.ZoneID == k.ZoneID
                                      select new
                                      {
                                          k.State,
                                          Name = (k.State == "0" ? "停用" : "啟用")
                                      }).FirstOrDefault(),
                             HaveCase = ((from g in DB.searchZone where g.ZoneID == a.ZoneID select g.Zone).FirstOrDefault() == null ? true : false)
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(result));
        }
        else if (type.Equals("AddZone"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];

            string Name = json.Name;
            var result = (from a in DB.Zone
                          where a.Name == Name
                          select a).FirstOrDefault();
            if (result == null)
            {
                var update = from b in DB.Zone
                             select b;
                foreach (var temp in update)
                {
                    temp.ZoneOrder = temp.ZoneOrder + 1;
                }
                DB.SubmitChanges();

                Zone st = new Zone
                {
                    Name = json.Name,
                    State = json.State,
                    ZoneOrder = 1
                };
                DB.Zone.InsertOnSubmit(st);
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已有相同行政區名稱存在！");
            }
        }
        else if (type.Equals("UpdateMyAD"))
        {
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            dynamic json = kaiValid.tranResToDynamic();
            var update = (from a in DB.UserLogin
                          where a.UserLoginID == user.UserLoginID
                          select a).SingleOrDefault();
            update.UserName = kaiValid.validNull(json.Name);
            string password = kaiValid.validNull(json.Password) + "";
            string codePassword = "";
            if (!password.Equals(""))
            {
                SHA256 sha256 = new SHA256CryptoServiceProvider();
                byte[] source = Encoding.Default.GetBytes(password);
                byte[] crypto = sha256.ComputeHash(source);
                codePassword = Convert.ToBase64String(crypto);
                update.Password = codePassword;
            }
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
        }
        else if (type.Equals("UpdateZone"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            int ZoneID = json.ZoneID;
            int ZoneOrder = json.ZoneOrder;
            string Name = json.Name;
            var result = (from a in DB.Zone
                          where a.Name == Name && a.ZoneID != ZoneID
                          select a).FirstOrDefault();
            if (result == null)
            {
                if (ZoneOrder != 0)
                {
                    int ZoneOrderBefore = json.ZoneOrderBefore;
                    if (ZoneOrder > ZoneOrderBefore)
                    {
                        var updateOrder = from x in DB.Zone
                                          where x.ZoneOrder <= ZoneOrder && x.ZoneOrder >= ZoneOrderBefore
                                          select x;
                        foreach (var temp in updateOrder)
                        {
                            temp.ZoneOrder = temp.ZoneOrder - 1;
                        }
                        DB.SubmitChanges();
                    }
                    else if (ZoneOrder < ZoneOrderBefore)
                    {
                        var updateOrder = from x in DB.Zone
                                          where x.ZoneOrder >= ZoneOrder && x.ZoneOrder <= ZoneOrderBefore
                                          select x;
                        foreach (var temp in updateOrder)
                        {
                            temp.ZoneOrder = temp.ZoneOrder + 1;
                        }
                        DB.SubmitChanges();
                    }
                }
                var update = (from c in DB.Zone
                              where c.ZoneID == ZoneID
                              select c).FirstOrDefault();

                if (ZoneOrder != 0)
                {
                    update.ZoneOrder = ZoneOrder;
                }
                update.Name = json.Name;
                update.State = json.State.State;
                DB.SubmitChanges();
                context.Response.ContentType = "text/plain";
                context.Response.Write("ok");
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("已有相同行政區名稱存在！");
            }
        }
        else if (type.Equals("DeleteUser"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            var del = (from a in DB.UserLogin
                       where a.UserLoginID == Convert.ToInt32(strJson)
                       select a).FirstOrDefault();
            int UserOrder = (int)del.UserOrder;

            var updateOrder = from x in DB.UserLogin
                              where x.UserOrder > UserOrder
                              select x;
            foreach (var temp in updateOrder)
            {
                temp.UserOrder = temp.UserOrder - 1;
            }
            DB.UserLogin.DeleteOnSubmit(del);
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
        }
        else if (type.Equals("DeleteZone"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            var del = (from a in DB.Zone
                       where a.ZoneID == Convert.ToInt32(strJson)
                       select a).FirstOrDefault();
            int ZoneOrder = (int)del.ZoneOrder;

            var updateOrder = from x in DB.Zone
                              where x.ZoneOrder > ZoneOrder
                              select x;
            foreach (var temp in updateOrder)
            {
                temp.ZoneOrder = temp.ZoneOrder - 1;
            }
            DB.Zone.DeleteOnSubmit(del);
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
        }
        else if (type.Equals("DeleteCouncilor"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
            user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
            var del = (from a in DB.CouncilorName
                       where a.CouncilorNameID == Convert.ToInt32(strJson)
                       select a).FirstOrDefault();
            int CouncilorNameOrder = (int)del.CouncilorNameOrder;

            var updateOrder = from x in DB.CouncilorName
                              where x.CouncilorNameOrder > CouncilorNameOrder
                              select x;
            foreach (var temp in updateOrder)
            {
                temp.CouncilorNameOrder = temp.CouncilorNameOrder - 1;
            }
            DB.CouncilorName.DeleteOnSubmit(del);
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
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

    public string getAdmin(string admin)
    {
        if (admin.Equals("0"))
        {
            return "否";
        }
        else if (admin.Equals("1"))
        {
            return "是";
        }
        else if (admin.Equals("2"))
        {
            return "super";
        }
        else
        {
            return "否";
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