// Copyright (c) Microsoft. All rights reserved.

using CopilotChat.WebApi.Options;
using System.Text.Json.Serialization;

namespace CopilotChat.WebApi.Models.Response;
public class FrontendUxConfig
{
    /// <summary>
    /// Override the default page titles and behaviour
    /// </summary>
    [JsonPropertyName("pageTitle")]
    public string PageTitle { get; set; }

    [JsonPropertyName("applicationName")]
    public string ApplicationName { get; set; }

    [JsonPropertyName("applicationNameVisible")]
    public bool ApplicationNameVisible { get; set; }

    [JsonPropertyName("copilotName")]
    public string CopilotName { get; set; }


    /// <summary>
    /// Theme options for overriding colours and custom logos
    /// </summary>
    [JsonPropertyName("primaryColor")]
    public string PrimaryColor { get; set; }

    [JsonPropertyName("secondaryColor")]
    public string SecondaryColor { get; set; }

    /// <summary>
    /// Graphics / logos
    /// </summary>
    [JsonPropertyName("pageLogoUrl")]
    public string PageLogoUrl { get; set; }

    [JsonPropertyName("faviconUrl")]
    public string FaviconUrl { get; set; }

    [JsonPropertyName("copilotAvatarUrl")]
    public string CopilotAvatarUrl { get; set; }


    /// <summary>
    /// For aged care scenario specifically, an english proficiency level
    /// this is used to adjust the prompt output for easier understanding
    /// </summary>
    [JsonPropertyName("englishProficiencyEnabled")]
    public bool EnglishProficiencyEnabled { get; set; }

    [JsonPropertyName("englishProficiencyDefaultLevel")]
    public int EnglishProficiencyDefaultLevel { get; set; }


    /// <summary>
    /// Visibility of UI elements
    /// </summary>
    [JsonPropertyName("documentsTabVisible")]
    public bool DocumentsTabVisible { get; set; }

    [JsonPropertyName("globalDocumentsVisible")]
    public bool GlobalDocumentsVisible { get; set; }

    [JsonPropertyName("plansTabVisible")]
    public bool PlansTabVisible { get; set; }

    [JsonPropertyName("chatHistoryVisible")]
    public bool ChatHistoryVisible { get; set; }

    [JsonPropertyName("pluginGalleryVisible")]
    public bool PluginGalleryVisible { get; set; }
}
