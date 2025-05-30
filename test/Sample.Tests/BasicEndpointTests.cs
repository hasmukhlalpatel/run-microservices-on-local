using Sample.Logging.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Threading.Tasks;

namespace Sample.Tests
{
    public class BasicEndpointTests : CustomWebApplicationFactory
    {
    public class BasicEndpointTests : CustomWebApplicationFactory

    [Test]
    public async Task Get_EndpointsReturnSuccessAndCorrectContentType()
        {
            string url = "/";
            string contentType = "text/plain";

            // Arrange
            var client = this.CreateClient();

            // Act
            var response = await client.GetAsync(url);
            var requestMessage = new HttpRequestMessage(HttpMethod.Get, url);
            var correlationId = Guid.NewGuid().ToString();
            requestMessage.Headers.Add(LoggingConstants.CorrelationId, correlationId);
            var response = await client.SendAsync(requestMessage);

            // Assert
            response.EnsureSuccessStatusCode(); // Status Code 200-299
            Assert.That(contentType == response.Content.Headers.ContentType.MediaType);
        }

     [Test]
    public async Task Get_Metadata()
        {
            string url = "/metadata";
            string tmpLogicalCallContext = "xUserId=Test1|Machine=ABC";

            // Arrange
            var client = this.CreateClient();

            // Act
            var response = await client.GetAsync(url);
            var requestMessage = new HttpRequestMessage(HttpMethod.Get, url);
            var correlationId = Guid.NewGuid().ToString();
            requestMessage.Headers.Add(LoggingConstants.CorrelationId, correlationId);
            requestMessage.Headers.Add(LoggingConstants.LogicalCallContext, tmpLogicalCallContex
    
            var response = await client.SendAsync(requestMessage);

            // Assert
            response.EnsureSuccessStatusCode(); // Status Code 200-299
            var content = await response.Content.ReadAsStringAsync();
            Assert.That(content.Contains(correlationId));
            Assert.That(content.Contains(tmpLogicalCallContext));
        }
    }
}
