using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// KaiValid 的摘要描述
/// </summary>
namespace KaiValid
{
    public class ValidJson
    {
        HttpContext context;
        public ValidJson(HttpContext val)
        {
            context = val;
        }
        public dynamic tranResToDynamic()
        {
            try
            {
                string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
                dynamic result = JValue.Parse(str);                
                return result;
            }
            catch
            {
                context.Response.Write("異常的使用者輸入！");
                context.Response.End();
                return false;
            }
        }
        public dynamic validNull(dynamic value)
        {
            if (value == null)
            {
                context.Response.Write("異常的使用者輸入！");
                context.Response.End();
            }
            return value;
        }
    }
}