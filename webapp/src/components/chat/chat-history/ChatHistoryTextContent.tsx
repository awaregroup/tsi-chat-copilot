// Copyright (c) Microsoft. All rights reserved.

import { makeStyles } from '@fluentui/react-components';
import React from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { IChatMessage } from '../../../libs/models/ChatMessage';
import * as utils from './../../utils/TextUtils';
const useClasses = makeStyles({
    content: {
        wordBreak: 'break-word',
    },
});

interface ChatHistoryTextContentProps {
    message: IChatMessage;
}

export const ChatHistoryTextContent: React.FC<ChatHistoryTextContentProps> = ({ message }) => {
    const classes = useClasses();
    const content = utils.replaceCitationLinksWithIndices(utils.formatChatTextContent(message.content), message);

    return (
        <div className={classes.content}>
            <ReactMarkdown remarkPlugins={[remarkGfm]} components={{
                a: props => {
                    if (props.href === undefined) return <></>;
                    
                    // enable links to open in new tab
                    return  <a href={props.href} target="_blank" rel="noreferrer">{props.children}</a> 
                }
            }}>{content}</ReactMarkdown>
        </div>
    );
};
