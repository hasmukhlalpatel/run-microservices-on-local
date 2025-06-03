using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Moq;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sample.Tests
{
    public class CustomWebApplicationFactory<TProgram>
    : WebApplicationFactory<TProgram> where TProgram : class
    {
        protected HttpMessageHandler Handler { get; private set; }
        public Dictionary<Type, Mock> MockedServices { get; } = new();
        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.UseEnvironment("UnitTest");

            builder.ConfigureServices(services =>
            {
                //ReplaceServiceWithMock<Microsoft.AspNetCore.Authentication.IAuthenticationService>(services);
                //ReplaceServiceWithMock<Microsoft.AspNetCore.Authorization.IAuthorizationService>(services);
                //ReplaceServiceWithMock<IHttpForwarder>(services); this is not used in the sample, but you can uncomment it if needed for revrse proxy yarp.
                
                var mockHandler = new Mock<HttpMessageHandler>();
                HttpMessageHandler handler = new TestHttpMessageHandler();
                var client = new HttpClient(handler) { BaseAddress = new Uri("http://localhost") };
                var clientFactoryMock = ReplaceServiceWithMock<IHttpClientFactory>(services);
                clientFactoryMock.Setup(x => x.CreateClient(It.IsAny<string>()))
                    .Returns(client);
                ReplaceService<HttpClient>(services, client);

                //ReplaceServiceWithMock<IDbContextOptionsConfiguration<ApplicationDbContext>>(services);
                //ReplaceServiceWithMock<DbConnection>(services);
               
                // Create open SqliteConnection so EF won't automatically close it.
                //services.AddSingleton<DbConnection>(container =>
                //{
                //    var connection = new SqliteConnection("DataSource=:memory:");
                //    connection.Open();

                //    return connection;
                //});

                //services.AddDbContext<ApplicationDbContext>((container, options) =>
                //{
                //    var connection = container.GetRequiredService<DbConnection>();
                //    options.UseSqlite(connection);
                //});
            });

            builder.UseEnvironment("Development");
        }
        protected void ReplaceService<TService>(IServiceCollection services, TService ImplementationInstance) where TService : class
        {
            var type = typeof(TService);
            RemoveService(services, type);
            services.AddSingleton(type, ImplementationInstance);
        }

        private static void RemoveService(IServiceCollection services, Type type)
        {
            var serviceDescriptor = services.FirstOrDefault(descriptor => descriptor.ServiceType == type);
            if (serviceDescriptor != null)
            {
                services.Remove(serviceDescriptor);
            }
        }

        protected Mock<TService> ReplaceServiceWithMock<TService>(IServiceCollection services) where TService : class
        {
            var type = typeof(TService);
            RemoveService(services, type);
            var mock = new Mock<TService>();
            MockedServices.Add(type, mock);
            services.AddSingleton(mock.Object);
            return mock;
        }

        class TestHttpMessageHandler : HttpMessageHandler
        {
            protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
            {
                return Task.FromResult(new HttpResponseMessage(System.Net.HttpStatusCode.OK));
            }
        }
    }
}
