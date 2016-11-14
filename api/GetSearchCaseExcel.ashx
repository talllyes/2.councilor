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

        }
        else if (type.Equals("setConfig"))
        {
            string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
            dynamic json = JValue.Parse(strJson);
            int excelFCol = 0;
            dynamic excelCol = json.excelCol;
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
            dynamic result = json.data;
            foreach (var temp in result)
            {
                IRow rowStat = u_sheet.CreateRow(i);
                for (int j = 0; j < excelFCol; j++)
                {
                    rowStat.CreateCell(j);
                    rowStat.GetCell(j).CellStyle = CsSet(12, true);
                }
                int rowCol = 0;
                if (excelCol.CaseBaseID == "check")
                {
                    string tt = temp.CaseBaseID + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.SuggestDate == "check")
                {
                    string tt = temp.SuggestDate + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.CouncilorName == "check")
                {
                    string tt = temp.CouncilorName.Name + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.ContactName == "check")
                {
                    string tt = temp.ContactName + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.ContactTel == "check")
                {
                    string tt = temp.ContactTel + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.Zone == "check")
                {
                    string tt = temp.Zone.Name + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.Address == "check")
                {
                    string tt = temp.Address + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.SuggestContent == "check")
                {
                    string tt = temp.SuggestContent + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.CaseOfficer == "check")
                {
                    string tt = temp.CaseOfficer.UserName + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.ExecuteContent == "check")
                {
                    string tt = temp.ExecuteContent + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }
                if (excelCol.State == "check")
                {
                    string tt = temp.OverDay + "";
                    rowStat.GetCell(rowCol).SetCellValue(tt);
                    rowCol = rowCol + 1;
                }

                i++;

            }
            MemoryStream MS = new MemoryStream();   //==需要 System.IO命名空間
            workbook.Write(MS);

            string fileLocation = context.Request.PhysicalApplicationPath;
            FileStream file = new FileStream(fileLocation + @"Excel\報表.xlsx", FileMode.Create);//產生檔案
            workbook.Write(file);
            file.Close();

            //== 釋放資源
            workbook = null;
            MS.Close();
            MS.Dispose();

            context.Response.Flush();
            context.Response.End();
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