<%@ WebHandler Language="C#" Class="webHook" %>

using System;
using System.Web;
using System.IO;
using System.Diagnostics;
using Newtonsoft.Json.Linq;


public class webHook : IHttpHandler {

    public void ProcessRequest (HttpContext context) {
        try
        {
            string jsonString = new StreamReader(context.Request.InputStream).ReadToEnd();
            JObject jsonObj = JObject.Parse(jsonString);
            string repo = (string)jsonObj["repository"]["name"];

            context.Response.ContentType = "text/plain";

            // depend on different repository, execute local or remote...
            switch(repo)
            {
                case "localRepository":
                    context.Response.Write(gitLocal());
                    break;
                case "remoteRepository":
                    gitRemote();
                    break;
            }
        }
        catch (Exception ex)
        {
            // error handler
        }
    }

    // execute git pull on local server usign windows command prompt,
    // and make sure administrator has permission to execute git without password.(ssh key)
    private string gitLocal()
    {
        ProcessStartInfo info = new ProcessStartInfo("cmd.exe");
        info.RedirectStandardInput = true;
        info.RedirectStandardOutput = true;
        info.UseShellExecute = false;
        // run as administrator
        info.Verb = "runas";

        Process p = Process.Start(info);

        if ( p != null )
        {
            // movie to target folder
            p.StandardInput.WriteLine(@"cd C:\C");

            // there was the weired point... even if run as administrator, but environment variable will not be change.
            // see blow output
            p.StandardInput.WriteLine("whoami");
            p.StandardInput.WriteLine("echo %USERPROFILE%");
            p.StandardInput.WriteLine("@set USERPROFILE=C:\\users\\administrator");
            p.StandardInput.WriteLine("@set HOME=C:\\users\\administrator");
            p.StandardInput.WriteLine("echo %USERPROFILE%");
            p.StandardInput.WriteLine("echo %HOME%");

            // pull from git repository
            p.StandardInput.WriteLine("git pull");
            p.StandardInput.Close();

            // output info to browser
            return p.StandardOutput.ReadToEnd();
        }

        return "something must wrong in gitLocal...";
    }

    // execute git pull on remote server usign windows powershell
    private void gitRemote()
    {
        ProcessStartInfo info = new ProcessStartInfo(@"C:\Windows\SysWOW64\WindowsPowershell\v1.0\powershell.exe");
        info.RedirectStandardInput = true;
        info.RedirectStandardOutput = true;
        info.UseShellExecute = false;
        // running powershell....
        info.Arguments = @"C:\doc\gitRemote.ps1";
        // run as administrator
        info.Verb = "runas";

        Process p = Process.Start(info);
        p.WaitForExit();
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}