using System.Collections;
using System.Reflection;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Management.Automation;

namespace PowerShellUniversal.Frameworks.Harness.Services;

public sealed class HarnessObjectNormalizer
{
    public object? NormalizeForJson(object? value)
    {
        return value switch
        {
            null => null,
            JsonElement element => NormalizeJsonElement(element),
            JsonNode node => node.Deserialize<object?>(),
            PSObject psObject => NormalizePsObject(psObject),
            IDictionary dictionary => NormalizeDictionary(dictionary),
            byte[] bytes => Convert.ToBase64String(bytes),
            IEnumerable enumerable when value is not string => NormalizeEnumerable(enumerable),
            Enum enumValue => enumValue.ToString(),
            _ when IsSimple(value.GetType()) => value,
            _ => NormalizeObject(value)
        };
    }

    public bool TryParseJson(string input, out object? value)
    {
        try
        {
            using var document = JsonDocument.Parse(input);
            value = NormalizeJsonElement(document.RootElement);
            return true;
        }
        catch (JsonException)
        {
            value = null;
            return false;
        }
    }

    private object? NormalizePsObject(PSObject psObject)
    {
        var baseObject = psObject.BaseObject;

        if (!ReferenceEquals(baseObject, psObject) && baseObject is not PSCustomObject)
        {
            return NormalizeForJson(baseObject);
        }

        if (!psObject.Properties.Any())
        {
            return baseObject is null || ReferenceEquals(baseObject, psObject)
                ? null
                : NormalizeForJson(baseObject);
        }

        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        foreach (var property in psObject.Properties)
        {
            if (!property.IsGettable)
            {
                continue;
            }

            result[property.Name] = NormalizeForJson(property.Value);
        }

        return result;
    }

    private static bool IsSimple(Type type)
    {
        return type.IsPrimitive
            || type == typeof(string)
            || type == typeof(decimal)
            || type == typeof(DateTime)
            || type == typeof(DateTimeOffset)
            || type == typeof(Guid)
            || type == typeof(TimeSpan)
            || type == typeof(Uri);
    }

    private object NormalizeDictionary(IDictionary dictionary)
    {
        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);

        foreach (DictionaryEntry entry in dictionary)
        {
            var key = Convert.ToString(entry.Key);
            if (string.IsNullOrWhiteSpace(key))
            {
                continue;
            }

            result[key] = NormalizeForJson(entry.Value);
        }

        return result;
    }

    private object NormalizeEnumerable(IEnumerable enumerable)
    {
        var result = new List<object?>();
        foreach (var item in enumerable)
        {
            result.Add(NormalizeForJson(item));
        }

        return result;
    }

    private object NormalizeObject(object value)
    {
        if (LooksLikeEndpointDescriptor(value))
        {
            return NormalizeEndpointDescriptor(value);
        }

        var properties = value
            .GetType()
            .GetProperties(BindingFlags.Instance | BindingFlags.Public)
            .Where(property => property.CanRead)
            .ToArray();

        if (properties.Length == 0)
        {
            return value.ToString() ?? string.Empty;
        }

        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        foreach (var property in properties)
        {
            result[property.Name] = NormalizeForJson(property.GetValue(value));
        }

        return result;
    }

    private object NormalizeEndpointDescriptor(object value)
    {
        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        AddEndpointProperty(result, value, "endpoint");
        AddEndpointProperty(result, value, "name");
        AddEndpointProperty(result, value, "accept");
        AddEndpointProperty(result, value, "contentType");
        AddEndpointProperty(result, value, "websocket");
        AddEndpointProperty(result, value, "javaScript");
        return result;
    }

    private static bool LooksLikeEndpointDescriptor(object value)
    {
        var properties = value.GetType().GetProperties(BindingFlags.Instance | BindingFlags.Public);
        return properties.Any(property => string.Equals(property.Name, "endpoint", StringComparison.OrdinalIgnoreCase))
            && properties.Any(property => string.Equals(property.Name, "name", StringComparison.OrdinalIgnoreCase));
    }

    private void AddEndpointProperty(Dictionary<string, object?> result, object value, string propertyName)
    {
        var property = value.GetType().GetProperties(BindingFlags.Instance | BindingFlags.Public)
            .FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));

        if (property is null || !property.CanRead)
        {
            return;
        }

        var propertyValue = property.GetValue(value);
        if (propertyValue is null)
        {
            return;
        }

        result[propertyName] = NormalizeForJson(propertyValue);
    }

    private object? NormalizeJsonElement(JsonElement element)
    {
        return element.ValueKind switch
        {
            JsonValueKind.Object => element.EnumerateObject().ToDictionary(
                property => property.Name,
                property => NormalizeJsonElement(property.Value),
                StringComparer.OrdinalIgnoreCase),
            JsonValueKind.Array => element.EnumerateArray().Select(NormalizeJsonElement).ToList(),
            JsonValueKind.String when element.TryGetDateTimeOffset(out var dto) => dto,
            JsonValueKind.String when element.TryGetGuid(out var guid) => guid,
            JsonValueKind.String => element.GetString(),
            JsonValueKind.Number when element.TryGetInt64(out var int64) => int64,
            JsonValueKind.Number => element.GetDouble(),
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.Null => null,
            _ => element.ToString()
        };
    }
}
