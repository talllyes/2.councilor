<%@ WebHandler Language="C#" Class="intersectionDetailExcel" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NPOI;
using NPOI.HSSF.UserModel;
using NPOI.XSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using NPOI.SS.Util;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Drawing.Imaging;
using System.Drawing;

public class intersectionDetailExcel : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    XSSFWorkbook workbook;
    DateTime searchEndDate;
    DateTime searchStartDate;
    string zone;
    string councilorName;
    string caseOfficer;
    string caseListSearch;
    public void ProcessRequest(HttpContext context)
    {
        string type = context.Items["type"].ToString();
        if (type.Equals("getExcel"))
        {
            DataClassesDataContext DB = new DataClassesDataContext();
            var taiwanCalendar = new System.Globalization.TaiwanCalendar();
            zone = context.Session["zone"].ToString();
            councilorName = context.Session["councilorName"].ToString();
            caseOfficer = context.Session["caseOfficer"].ToString();
            caseListSearch = context.Session["caseListSearch"].ToString();
            string dataTemp = (Convert.ToInt32(context.Session["searchStartDate"].ToString().Split('-')[0]) + 1911).ToString();
            dataTemp = dataTemp + "-" + context.Session["searchStartDate"].ToString().Split('-')[1] + "-" + context.Session["searchStartDate"].ToString().Split('-')[2];
            searchStartDate = Convert.ToDateTime(dataTemp);
            dataTemp = (Convert.ToInt32(context.Session["searchEndDate"].ToString().Split('-')[0]) + 1911).ToString();
            dataTemp = dataTemp + "-" + context.Session["searchEndDate"].ToString().Split('-')[1] + "-" + context.Session["searchEndDate"].ToString().Split('-')[2];
            searchEndDate = Convert.ToDateTime(dataTemp);
            string excelType = context.Session["excelType"].ToString();
            dynamic excelCol = JValue.Parse(context.Session["excelCol"].ToString());
            if (caseOfficer.Equals(""))
            {

            }

            int zoneID = (from a in DB.Zone
                          where a.Name == zone
                          select a.ZoneID).FirstOrDefault();

            int councilorNameID = (from a in DB.CouncilorName
                                   where a.Name == councilorName
                                   select a.CouncilorNameID).FirstOrDefault();

            List<CaseBaseR> resultTmp = (from a in DB.CaseBase
                                         orderby a.SuggestDate descending
                                         select new CaseBaseR()
                                         {
                                             CaseBaseID = a.CaseBaseID,
                                             SuggestDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(a.SuggestDate.ToString())), a.SuggestDate),
                                             UnitID = (int)(from d in DB.UserLogin where d.UserLoginID == a.CaseOfficerID select d.Unit).SingleOrDefault(),
                                             SuggestContent = a.SuggestContent,
                                             SuggestDateY = a.SuggestDate,
                                             CaseOfficerID = (int)a.CaseOfficerID,
                                             CouncilorName = (from b in DB.CouncilorName where a.CouncilorNameID == b.CouncilorNameID select b.Name).FirstOrDefault(),
                                             Zone = (from b in DB.Zone where a.ZoneID == b.ZoneID select b.Name).FirstOrDefault(),
                                             Address = a.Address,
                                             CaseOfficer = (from b in DB.UserLogin where a.CaseOfficerID == b.UserLoginID select b.UserName).FirstOrDefault(),
                                             ContactName = a.ContactName,
                                             ContactTel = a.ContactTel,
                                             EndDate = yearTr(a.EndDate.ToString()),
                                             ExecuteContent = a.ExecuteContent,
                                             State = a.State,
                                             OverDay = getOverDay(a.State, a.ExecuteContent + "", a.SuggestDate, a.EndDate.ToString()),
                                             OverDayInt = getOverDayInt(a.State, a.ExecuteContent + "", a.SuggestDate, a.EndDate.ToString())
                                         }).ToList();
            List<CaseBaseR> result = new List<CaseBaseR>();
            if (excelType.Equals("WaitCase"))
            {
                foreach (var temp in resultTmp)
                {
                    bool flag = true;
                    flag = checkSearch(temp);
                    if (!temp.EndDate.Equals(""))
                    {
                        flag = false;
                    }
                    if (flag)
                    {
                        result.Add(temp);
                    }
                }
            }
            else if (excelType.Equals("CaseSearchAll"))
            {
                foreach (var temp in resultTmp)
                {
                    bool flag = true;
                    flag = checkSearch(temp);
                    if (flag)
                    {
                        result.Add(temp);
                    }
                }
            }
            else if (excelType.Equals("YearSearch"))
            {
                KaiNamespace.LoginSession user = new KaiNamespace.LoginSession();
                user = (KaiNamespace.LoginSession)context.Session["councilorLogin"];
                foreach (var temp in resultTmp)
                {
                    bool flag = true;
                    flag = checkSearch(temp);
                    if (!temp.EndDate.Equals(""))
                    {
                        flag = false;
                    }
                    if (!temp.State.Equals("2"))
                    {
                        flag = false;
                    }
                    if (flag)
                    {
                        result.Add(temp);
                    }
                }
            }
            else if (excelType.Equals("OverDateSearch"))
            {
                foreach (var temp in resultTmp)
                {
                    bool flag = true;
                    flag = checkSearch(temp);
                    if (!temp.EndDate.Equals(""))
                    {
                        flag = false;
                    }
                    if (temp.OverDayInt == 0)
                    {
                        flag = false;
                    }
                    if (flag)
                    {
                        result.Add(temp);
                    }
                }
            }
            else if (excelType.Equals("EndSearch"))
            {
                foreach (var temp in resultTmp)
                {
                    bool flag = true;
                    flag = checkSearch(temp);
                    if (temp.EndDate.Equals(""))
                    {
                        flag = false;
                    }
                    if (flag)
                    {
                        result.Add(temp);
                    }
                }
            }

            int excelFCol = 0;
            foreach (var temp in excelCol)
            {
                string a = (string)temp;
                if (a.Equals("check"))
                {
                    excelFCol = excelFCol + 1;
                }
            }
            context.Response.Clear();
            workbook = new XSSFWorkbook();
            XSSFSheet u_sheet = (XSSFSheet)workbook.CreateSheet("表一");
            SetSheet(u_sheet);
            int i = 0;
            IRow rowHead = u_sheet.CreateRow(i);
            for (int j = 0; j < excelFCol; j++)
            {
                rowHead.CreateCell(j);
                rowHead.GetCell(j).CellStyle = CsSet(12, true, true);
            }
            int setExcelCol = 0;
            if (excelCol.CaseBaseID == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 7 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("編號");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.SuggestDate == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 15 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("建議日期");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.CouncilorName == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 12 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("建議民代");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.ContactName == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 12 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("聯絡人");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.ContactTel == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 15 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("聯絡電話");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.Zone == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 12 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("行政區");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.Address == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 40 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("建議路口/段");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.SuggestContent == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 50 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("建議事項");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.CaseOfficer == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 12 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("承辦人");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.ExecuteContent == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 50 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("辦理情形");
                setExcelCol = setExcelCol + 1;
            }
            if (excelCol.State == "check")
            {
                u_sheet.SetColumnWidth(setExcelCol, 12 * 256);
                rowHead.GetCell(setExcelCol).SetCellValue("案件狀態");
                setExcelCol = setExcelCol + 1;
            }

            i = i + 1;
            XSSFCellStyle aa = CsSet(12, true);
            foreach (var temp in result)
            {
                IRow rowStat = u_sheet.CreateRow(i);
                string searchS = temp.CaseBaseID + temp.SuggestDate + temp.CouncilorName + temp.ContactName + temp.ContactTel + temp.Zone;
                searchS = searchS + temp.Address + temp.SuggestContent + temp.CaseOfficer + temp.ExecuteContent + temp.OverDay;
                if (searchS.IndexOf(caseListSearch) != -1)
                {

                    for (int j = 0; j < excelFCol; j++)
                    {
                        rowStat.CreateCell(j);
                        rowStat.GetCell(j).CellStyle = aa;
                    }
                    int rowCol = 0;
                    if (excelCol.CaseBaseID == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.CaseBaseID);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.SuggestDate == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.SuggestDate);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.CouncilorName == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.CouncilorName);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.ContactName == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.ContactName);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.ContactTel == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.ContactTel);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.Zone == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.Zone);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.Address == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.Address);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.SuggestContent == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.SuggestContent);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.CaseOfficer == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.CaseOfficer);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.ExecuteContent == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.ExecuteContent);
                        rowCol = rowCol + 1;
                    }
                    if (excelCol.State == "check")
                    {
                        rowStat.GetCell(rowCol).SetCellValue(temp.OverDay);
                        rowCol = rowCol + 1;
                    }

                    i++;
                }
            }
            MemoryStream MS = new MemoryStream();   //==需要 System.IO命名空間
            workbook.Write(MS);

            //== Excel檔名，請寫在最後面 filename的地方
            context.Response.AddHeader("Content-Disposition", "attachment; filename=" + DateTime.Now.ToString("yyyyMMddhhmm") + ".xlsx");
            context.Response.BinaryWrite(MS.ToArray());

            //== 釋放資源
            workbook = null;
            MS.Close();
            MS.Dispose();

            context.Response.Flush();
            context.Response.End();
        }
        else if (type.Equals("setConfig"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            context.Session["zone"] = json.zone;
            context.Session["councilorName"] = json.councilorName;
            context.Session["caseOfficer"] = json.caseOfficer;
            context.Session["searchStartDate"] = json.searchStartDate;
            context.Session["searchEndDate"] = json.searchEndDate;
            context.Session["caseListSearch"] = json.caseListSearch;
            context.Session["excelType"] = json.excelType;
            context.Session["excelCol"] = json.excelCol;
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    public XSSFCellStyle CsSet(short size, bool x, bool y)
    {
        XSSFFont font = (XSSFFont)workbook.CreateFont();
        font.FontName = "微軟正黑體";
        font.FontHeightInPoints = size;
        XSSFCellStyle cs = (XSSFCellStyle)workbook.CreateCellStyle();
        cs.SetFont(font);
        cs.WrapText = true;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Center;
        if (x)
        {
            cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.WrapText = true;
        }
        if (y)
        {
            cs.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.Grey40Percent.Index;
            cs.FillPattern = NPOI.SS.UserModel.FillPattern.SolidForeground;

        }
        return cs;
    }


    public XSSFCellStyle CsSet(short size, bool x)
    {

        XSSFFont font = (XSSFFont)workbook.CreateFont();
        font.FontName = "微軟正黑體";
        font.FontHeightInPoints = size;
        XSSFCellStyle cs = (XSSFCellStyle)workbook.CreateCellStyle();
        cs.SetFont(font);
        cs.WrapText = true;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Center;
        if (x)
        {
            cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.WrapText = true;
        }
        return cs;
    }

    public void SetSheet(XSSFSheet s)
    {
        s.PrintSetup.Landscape = true;
        s.FitToPage = true;
        s.SetRowBreak(22);
        s.PrintSetup.FitWidth = 1;
        s.PrintSetup.FitHeight = 0;
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

    public class CaseBaseR
    {

        public int CaseBaseID;
        public DateTime SuggestDateY;
        public string SuggestDate;
        public string SuggestContent;
        public string CouncilorName;
        public string Zone;
        public string Address;
        public string CaseOfficer;
        public string ContactName;
        public string ContactTel;
        public string EndDate;
        public string ExecuteContent;
        public string State;
        public string OverDay;
        public int OverDayInt;
        public int CaseOfficerID;
        public int UnitID;
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
    public bool checkSearch(CaseBaseR temp)
    {
        bool flag = true;
        string searchStr = temp.CaseBaseID + temp.SuggestDate + temp.CouncilorName + temp.Zone + temp.Address + temp.SuggestContent + temp.OverDay + temp.CaseOfficer;
        if (searchStr.IndexOf(caseListSearch) == -1)
        {
            flag = false;
        }
        if (temp.Zone.IndexOf(zone) == -1)
        {
            flag = false;
        }
        if (temp.CouncilorName.IndexOf(councilorName) == -1)
        {
            flag = false;
        }
        if (temp.CaseOfficer.IndexOf(caseOfficer) == -1)
        {
            flag = false;
        }
        if (temp.SuggestDateY < searchStartDate)
        {
            flag = false;
        }
        if (temp.SuggestDateY > searchEndDate)
        {
            flag = false;
        }
        return flag;
    }
}