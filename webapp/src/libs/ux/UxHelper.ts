import debug from 'debug';
import { Constants } from '../../Constants';
import { store } from '../../redux/app/store';

const log = debug(Constants.debug.root).extend('authHelper');

export interface UxConfig {
    pageTitle: string;
    applicationName: string;
    applicationNameVisible: boolean;
    copilotName: string;
    primaryColor: string;
    secondaryColor: string;
    pageLogoUrl: string;
    faviconUrl: string;
    copilotAvatarUrl: string;
    englishProficiencyEnabled: boolean;
    englishProficiencyDefaultLevel: number;
    documentsTabVisible: boolean;
    globalDocumentsVisible: boolean;
    plansTabVisible: boolean;
    chatHistoryVisible: boolean;
}