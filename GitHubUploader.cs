using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Diagnostics;
using System.Collections.Generic;

namespace GitHubUploaderApp
{
    class Program
    {
        static void Main(string[] args)
        {
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072 | (SecurityProtocolType)768;

            Console.ForegroundColor = ConsoleColor.DarkYellow;
            Console.WriteLine("==================================================================");
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("   SIPPICOM GITHUB REPOSITORY PUBLISHER (API Engine)");
            Console.ForegroundColor = ConsoleColor.DarkYellow;
            Console.WriteLine("==================================================================\n");
            Console.ResetColor();

            // 1. Get GH CLI Token and User
            string ghPath = @"C:\Program Files\GitHub CLI\gh.exe";
            if (!File.Exists(ghPath))
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("GitHub CLI (gh.exe) not found at: " + ghPath);
                Console.ResetColor();
                return;
            }

            string token = RunProcess(ghPath, "auth token").Trim();
            if (string.IsNullOrEmpty(token) || token.Contains("failed") || token.Contains("error"))
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Could not retrieve GitHub auth token. Please run 'gh auth login' in terminal.");
                Console.ResetColor();
                return;
            }

            string user = RunProcess(ghPath, "api user --jq .login").Trim();
            if (string.IsNullOrEmpty(user) || user.Contains("error"))
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Could not get authenticated GitHub user.");
                Console.ResetColor();
                return;
            }

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("✓ Authenticated with GitHub as: " + user);
            Console.ResetColor();

            string repoName = "sippicom-tools";
            if (args.Length > 0 && !string.IsNullOrEmpty(args[0]))
            {
                repoName = args[0];
            }

            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("SippicomUploader", "1.0"));
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github.v3+json"));

                // 2. Check if repository exists or create it
                string checkUrl = "https://api.github.com/repos/" + user + "/" + repoName;
                HttpResponseMessage checkRes = client.GetAsync(checkUrl).Result;

                if (checkRes.StatusCode == HttpStatusCode.NotFound)
                {
                    Console.ForegroundColor = ConsoleColor.Cyan;
                    Console.WriteLine("--> Creating public repository: " + user + "/" + repoName + " ...");
                    Console.ResetColor();

                    string createJson = "{\"name\":\"" + repoName + "\",\"description\":\"SIPPICOM Cloud IT Tools & Workstation AutoDeploy Suite (irm | iex)\",\"private\":false,\"auto_init\":true}";
                    var createContent = new StringContent(createJson, Encoding.UTF8, "application/json");
                    HttpResponseMessage createRes = client.PostAsync("https://api.github.com/user/repos", createContent).Result;

                    if (!createRes.IsSuccessStatusCode)
                    {
                        string err = createRes.Content.ReadAsStringAsync().Result;
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("Failed to create repository: " + err);
                        Console.ResetColor();
                        return;
                    }
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine("✓ Repository created successfully!");
                    Console.ResetColor();
                    System.Threading.Thread.Sleep(2000); // Give GitHub a moment to initialize
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine("✓ Repository " + user + "/" + repoName + " exists.");
                    Console.ResetColor();
                }

                // 3. Upload all files
                string rootDir = @"C:\Users\aguerster\Documents\__Projects\GitHub_Repo";
                string targetUrl = "https://raw.githubusercontent.com/" + user + "/" + repoName + "/main";

                var files = Directory.GetFiles(rootDir, "*.*", SearchOption.AllDirectories);
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("\n--> Uploading " + files.Length + " files to GitHub main branch...");
                Console.ResetColor();

                foreach (string filePath in files)
                {
                    string fileName = Path.GetFileName(filePath);
                    if (fileName == "prepare_push.ps1" || fileName == "PublishToGitHub.ps1" || fileName.EndsWith(".cs") || fileName.EndsWith(".exe") && fileName == "GitHubUploader.exe")
                    {
                        continue;
                    }

                    string relPath = filePath.Substring(rootDir.Length).TrimStart('\\').Replace('\\', '/');
                    Console.Write("    Uploading " + relPath + " ... ");

                    byte[] contentBytes = File.ReadAllBytes(filePath);

                    // Replace template URLs in script files
                    string ext = Path.GetExtension(filePath).ToLower();
                    if (ext == ".ps1" || ext == ".md" || ext == ".txt")
                    {
                        string text = Encoding.UTF8.GetString(contentBytes);
                        text = text.Replace("https://raw.githubusercontent.com/sippicom/tools/main", targetUrl);
                        contentBytes = Encoding.UTF8.GetBytes(text);
                    }

                    string b64 = Convert.ToBase64String(contentBytes);

                    // Check existing file SHA
                    string fileApiUrl = "https://api.github.com/repos/" + user + "/" + repoName + "/contents/" + relPath;
                    HttpResponseMessage getRes = client.GetAsync(fileApiUrl).Result;
                    string sha = null;
                    if (getRes.IsSuccessStatusCode)
                    {
                        string body = getRes.Content.ReadAsStringAsync().Result;
                        int idx = body.IndexOf("\"sha\":");
                        if (idx >= 0)
                        {
                            int start = body.IndexOf('"', idx + 6) + 1;
                            int end = body.IndexOf('"', start);
                            sha = body.Substring(start, end - start);
                        }
                    }

                    // PUT File
                    string putJson = "{\"message\":\"Upload " + relPath + "\",\"content\":\"" + b64 + "\"" + (sha != null ? ",\"sha\":\"" + sha + "\"" : "") + ",\"branch\":\"main\"}";
                    var putContent = new StringContent(putJson, Encoding.UTF8, "application/json");
                    HttpResponseMessage putRes = client.PutAsync(fileApiUrl, putContent).Result;

                    if (putRes.IsSuccessStatusCode)
                    {
                        Console.ForegroundColor = ConsoleColor.Green;
                        Console.WriteLine("✓ OK");
                    }
                    else
                    {
                        Console.ForegroundColor = ConsoleColor.Yellow;
                        Console.WriteLine("Status: " + putRes.StatusCode);
                    }
                    Console.ResetColor();
                }

                Console.ForegroundColor = ConsoleColor.DarkYellow;
                Console.WriteLine("\n==================================================================");
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("   🎉 ALL SIPPICOM CLOUD TOOLS PUBLISHED TO GITHUB!");
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("   Repository: https://github.com/" + user + "/" + repoName);
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("   Cloud Hub:  irm " + targetUrl + "/main.ps1 | iex");
                Console.ForegroundColor = ConsoleColor.DarkYellow;
                Console.WriteLine("==================================================================");
                Console.ResetColor();
            }
        }

        static string RunProcess(string exe, string args)
        {
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = exe,
                    Arguments = args,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };
                using (Process p = Process.Start(psi))
                {
                    string s = p.StandardOutput.ReadToEnd();
                    p.WaitForExit();
                    return s;
                }
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }
    }
}
