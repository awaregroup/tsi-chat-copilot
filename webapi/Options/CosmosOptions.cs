// Copyright (c) Microsoft. All rights reserved.

using System.ComponentModel.DataAnnotations;

namespace CopilotChat.WebApi.Options;

public enum AuthTypes
{
    Unknown = -1,
    AzureIdentity,
    ConnectionString
}

/// <summary>
/// Configuration settings for connecting to Azure CosmosDB.
/// </summary>
public class CosmosOptions
{
    /// <summary>
    /// Defines whether to use Managed Identity or ConnectionString
    /// </summary>
    [Required, NotEmptyOrWhitespace]
    public AuthTypes Auth { get; set; } = AuthTypes.Unknown;

    /// <summary>
    /// Gets or sets the Cosmos database name.
    /// </summary>
    [Required, NotEmptyOrWhitespace]
    public string Database { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the Cosmos connection string.
    /// </summary>
    [RequiredOnPropertyValue(nameof(AuthTypes), AuthTypes.ConnectionString)]
    public string ConnectionString { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the Cosmos endpoint.
    /// </summary>
    [RequiredOnPropertyValue(nameof(AuthTypes), AuthTypes.AzureIdentity)]
    public string Endpoint { get; set; } = string.Empty;


    /// <summary>
    /// Gets or sets the Cosmos container for chat sessions.
    /// </summary>
    [Required, NotEmptyOrWhitespace]
    public string ChatSessionsContainer { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the Cosmos container for chat messages.
    /// </summary>
    [Required, NotEmptyOrWhitespace]
    public string ChatMessagesContainer { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the Cosmos container for chat memory sources.
    /// </summary>
    [Required, NotEmptyOrWhitespace]
    public string ChatMemorySourcesContainer { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the Cosmos container for chat participants.
    /// </summary>
    [Required, NotEmptyOrWhitespace]
    public string ChatParticipantsContainer { get; set; } = string.Empty;
}
