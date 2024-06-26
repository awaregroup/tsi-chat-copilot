// import debug from 'debug';
// import { Constants } from '../../Constants';

// const log = debug(Constants.debug.root).extend('authHelper');

export interface UxConfig {
    pageTitle: string;
    applicationName: string;
    applicationNameVisible: boolean;
    copilotName: string;
    primaryColor: string;
    secondaryColor: string;
    headerTextColor: string;
    pageLogoUrl: string;
    faviconUrl: string;
    copilotAvatarUrl: string;
    englishProficiencyEnabled: boolean;
    englishProficiencyDefaultLevel: number;
    documentsTabVisible: boolean;
    globalDocumentsVisible: boolean;
    plansTabVisible: boolean;
    personasTabVisible: boolean;
    promptDetailVisible: boolean;
    chatHistoryVisible: boolean;
    pluginGalleryVisible: boolean;
    userSettingsVisible: boolean;
}