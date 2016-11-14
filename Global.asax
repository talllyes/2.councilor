<%@ Application Language="C#" %>
<%@ Import Namespace="System.Web.Routing" %>

<script RunAt="server">

    void Application_Start(object sender, EventArgs e)
    {
        // 在應用程式啟動時執行的程式碼
        RegisterRoutes(RouteTable.Routes);
    }

    void RegisterRoutes(RouteCollection routes)
    {
        //加入路徑設定
        routes.Add("api", new Route("api/{model}/{type}", new KaiNamespace.ApiRoute()));
        routes.Add("login", new Route("login", new KaiNamespace.HtmlRoute()));
        routes.Add("index", new Route("index", new KaiNamespace.HtmlRoute()));
    }

    void Application_End(object sender, EventArgs e)
    {
        //  在應用程式關閉時執行的程式碼

    }

    void Application_Error(object sender, EventArgs e)
    {
        // 在發生未處理的錯誤時執行的程式碼
        //Response.Redirect("~/login");
    }

    void Session_Start(object sender, EventArgs e)
    {
        // 在新的工作階段啟動時執行的程式碼
        DataClasses2DataContext DB = new DataClasses2DataContext();
        var r = (from a in DB.loginNum where a.SystemType == "2system" select a).FirstOrDefault();
        DateTime s = (DateTime)r.LoginDate;
        if (DateTime.Now.ToString("yyyyMMdd") != s.ToString("yyyyMMdd"))
        {
            r.LoginID = "1";
            r.LoginDate = DateTime.Now;
        }
        else
        {
            r.LoginID = (Convert.ToInt32(r.LoginID) + 1).ToString();
            r.LoginDate = DateTime.Now;
        }
        DB.SubmitChanges();
    }

    void Application_AcquireRequestState(Object sender, EventArgs e)
    {
        if (HttpContext.Current.Session != null)
        {
            string url = Request.RawUrl;
            if (url.IndexOf("index") != -1)
            {
                if (HttpContext.Current.Session["councilorLogin"] == null)
                {
                    Response.Redirect("~/login");
                }
            }
            if (Request.RawUrl.IndexOf("api") != -1 && Request.RawUrl.IndexOf("login") == -1)
            {
                if (HttpContext.Current.Session["councilorLogin"] == null)
                {
                    Response.Redirect("~/login");
                }
            }
        }
    }

    void Session_End(object sender, EventArgs e)
    {
        // 在工作階段結束時執行的程式碼
        // 注意: 只有在  Web.config 檔案中將 sessionstate 模式設定為 InProc 時，
        // 才會引起 Session_End 事件。如果將 session 模式設定為 StateServer 
        // 或 SQLServer，則不會引起該事件。
        DataClasses2DataContext DB = new DataClasses2DataContext();
        var r = (from a in DB.loginNum where a.SystemType == "2system" select a).FirstOrDefault();
        if (Convert.ToInt32(r.LoginID) > 0)
        {
            r.LoginID = (Convert.ToInt32(r.LoginID) - 1).ToString();
        }
        DB.SubmitChanges();
    }

</script>
