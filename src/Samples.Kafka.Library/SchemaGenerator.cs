using NJsonSchema.NewtonsoftJson.Generation;

namespace Samples.Kafka.Library
{
    public class SchemaGenerator
    {

        public static string GenerateSchema<T>() => NewtonsoftJsonSchemaGenerator.FromType<T>(new NewtonsoftJsonSchemaGeneratorSettings
        {
            SerializerSettings = new Newtonsoft.Json.JsonSerializerSettings
            {
                TypeNameHandling = Newtonsoft.Json.TypeNameHandling.Auto,
                Formatting = Newtonsoft.Json.Formatting.Indented,
                //Converters = [new Samples.Serialization.Library.PolymorphicJsonConverter<T>()]

            }
        }).ToJson();
    }
}
