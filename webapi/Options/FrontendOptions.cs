// Copyright (c) Microsoft. All rights reserved.

namespace CopilotChat.WebApi.Options;

/// <summary>
/// Configuration options to be relayed to the frontend.
/// </summary>
public sealed class FrontendOptions
{
    public const string PropertyName = "Frontend";

    /// <summary>
    /// Client ID for the frontend
    /// </summary>
    public string AadClientId { get; set; } = string.Empty;


    /// <summary>
    /// Override the default page titles and behaviour
    /// </summary>
    public string PageTitle { get; set; } = "Enterprise Copilot";
    public string ApplicationName { get; set; } = "Chat Copilot";
    public bool ApplicationNameVisible { get; set; } = true;
    public string CopilotName { get; set; } = "Copilot";


    /// <summary>
    /// Theme options for overriding colours and custom logos
    /// </summary>
    public string PrimaryColor { get; set; } = "#A53E63";
    public string SecondaryColor { get; set; } = "#A53E63";

    /// <summary>
    /// Graphics / logos
    /// </summary>
    public string PageLogoUrl { get; set; }
    public string FaviconUrl { get; set; }
    public string CopilotAvatarUrl { get; set; }


    /// <summary>
    /// For aged care scenario specifically, an english proficiency level
    /// this is used to adjust the prompt output for easier understanding
    /// </summary>
    public bool EnglishProficiencyEnabled { get; set; } = true;
    public int EnglishProficiencyDefaultLevel { get; set; } = 4;


    /// <summary>
    /// Visibility of UI elements
    /// </summary>
    public bool DocumentsTabVisible { get; set; } = true;
    public bool GlobalDocumentsVisible { get; set; } = true;
    public bool PlansTabVisible { get; set; } = true;
    public bool ChatHistoryVisible { get; set; } = true;
}
