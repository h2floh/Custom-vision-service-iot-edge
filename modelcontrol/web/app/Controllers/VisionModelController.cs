using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using app.Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;

namespace app.Controllers
{
    public class VisionModelController : Controller
    {
        private List<VisionModelModel> modelList;
        private List<DeviceModel> deviceList;
        private List<IoTHubModel> hubList;
        private static readonly string modelControlUrl = Environment.GetEnvironmentVariable("API_URL");
        private static readonly string modelControlAuthKey = Environment.GetEnvironmentVariable("API_AUTH_KEY");

        public VisionModelController()
        {
            modelList = new List<VisionModelModel>
            {  
                new VisionModelModel { Name = "fire" },
                new VisionModelModel { Name = "fire_s1" },
                new VisionModelModel { Name = "door" },
                new VisionModelModel { Name = "door_s1" },
                new VisionModelModel { Name = "applebanana" },
                new VisionModelModel { Name = "camonly" }
            };

            deviceList = new List<DeviceModel>
            {
                new DeviceModel { Name = "pi-iotedge" }
            };

            hubList = new List<IoTHubModel>
            {
                new IoTHubModel { Name = "cse" }
            };
        }

        public IActionResult Index()
        {
            ViewData["models"] = modelList;
            ViewData["hubs"] = hubList;
            ViewData["devices"] = deviceList;
            return View();
        }


        public string Welcome(string name, int numTimes = 1)
        {
            return HtmlEncoder.Default.Encode($"Hello {name}, NumTimes is: {numTimes}");
        }


        [HttpPost]
        public async Task<IActionResult> Change(string Model, string Hub, string DeviceId)
        {
            ViewData["result"] = await ChangeModel(Model, Hub, DeviceId);
            return View("Result");
        }


        private async Task<string> ChangeModel(string model, string hub, string deviceId)
        {
            try { 
                // Create a WebRequest to get the file
                var URL = modelControlUrl;
                HttpWebRequest fileReq = (HttpWebRequest)HttpWebRequest.Create(URL);
                // Set the Method property of the request to POST.  
                fileReq.Method = "POST";
                // Set the ContentType property of the WebRequest.  
                fileReq.ContentType = @"application/json";
                fileReq.Headers.Add(@"AuthKey", modelControlAuthKey);

                var inputs = new
                {
                    model,
                    deviceId,
                    hubName = hub
                };

                // Create POST data and convert it to a byte array.
                string postData = JsonConvert.SerializeObject(inputs);
                byte[] byteArray = Encoding.UTF8.GetBytes(postData);

                // Set the ContentLength property of the WebRequest.  
                fileReq.ContentLength = byteArray.Length;
                // Get the request stream.  
                Stream dataStream = fileReq.GetRequestStream();
                // Write the data to the request stream.  
                dataStream.Write(byteArray, 0, byteArray.Length);
                // Close the Stream object.  
                dataStream.Close();

                //Create a response for this request
                HttpWebResponse fileResp = (HttpWebResponse)await fileReq.GetResponseAsync();

                dataStream = fileResp.GetResponseStream();
                // Open the stream using a StreamReader for easy access.  
                StreamReader reader = new StreamReader(dataStream);
                // Read the content.  
                //string responseFromServer = reader.ReadToEnd();
                string results = reader.ReadToEnd();

                reader.Close();
                dataStream.Close();
                fileResp.Close();

                return results;
            }
            catch (Exception e)
            {
                return e.Message + e.StackTrace;
            }
        }
    }
}