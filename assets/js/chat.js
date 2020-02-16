const chatVersion = '1.17.3'

const loadJsAsync = deps => loadjs(deps, {
    async: true,
    returnPromise: true
})

const log = (...args) =>
    console.log(
        '%cChat',
        'background-color: #3543ec; color: #ffffff; padding: 0.25rem;',
        ...args,
    )

const logError = (...args) =>
    console.error(
        '%cChat',
        'background-color: #da2525; color: #ffffff; padding: 0.25rem;',
        ...args,
    )

const loadChat = () => {
    const context = document.querySelector("meta[name='chat:context']")
    if (!context) {
        return Promise.reject('No chat context defined!')
    }
    return loadJsAsync([
        'https://cdnjs.cloudflare.com/ajax/libs/react/16.12.0/umd/react.production.min.js',
        'https://cdnjs.cloudflare.com/ajax/libs/react-dom/16.11.0/umd/react-dom.production.min.js',
        'https://media.twiliocdn.com/sdk/js/chat/v3.3/twilio-chat.min.js',
        'https://twemoji.maxcdn.com/v/latest/twemoji.min.js',
    ])
        .then(() => loadJsAsync([
            `https://github.com/distributeaid/chat-ui/releases/download/v${chatVersion}/distribute-aid-chat-ui.v${chatVersion}.js`,
        ]))
        .then(() => {
            DAChat({
                context: context.getAttribute("content"),
                apiKey: document.querySelector("meta[name='chat:apiKey']").getAttribute("content"),
                apiEndpoint: document.querySelector("meta[name='chat:endpoint']").getAttribute("content"),
                token: document.querySelector("meta[name='chat:jwt']").getAttribute("content"),
            })
        })
}

window.onload = () => {
    if (window.localStorage.getItem('DAChat:enabled') === '1') {
        const token = document.querySelector("meta[name='chat:jwt']")
        if (!token) {
            log('Chat disabled: no token present in page.')
            return
        }
        if (document.cookie.split(';').filter((item) => item.trim().startsWith('DAChatopen=')).length) {
            loadChat()
                .catch(logError)
        } else {
            loadJsAsync([
                `https://github.com/distributeaid/chat-ui/releases/download/v${chatVersion}/distribute-aid-chat-button.v${chatVersion}.js`
            ])
                .then(() => {
                    DAChatButton((removeButton) => {
                        document.cookie = 'DAChatopen=1'
                        loadChat()
                            .then(() => {
                                removeButton()
                            })
                    })
                })
                .catch(logError)
        }
    } else {
        log('Chat disabled. Run this command to enable it for this browser and reload the page:')
        log(`window.localStorage.setItem('DAChat:enabled', '1')`)
    }
}