const TypstCli = require("./typst-cli");
const {moment} = require("hexo/lib/plugins/helper/date");


class TypstExcerptGenerator {
    constructor(hexo) {
        this.hexo = hexo;
        this.typstCli = new TypstCli(hexo);
        this.maxAbstractContentLength = 220
    }

    process(local) {
        //console.log(`input type: ${typeof local}, local: ${local.tags}, posts: ${local.posts}`);

        return local.posts.map(post => {
            this.processPost(post);
        });
    }

    findAbstractInContent(content) {
        const lines = content.split(/\n/).filter(line => line.trim() !== '');
        const index = lines.findIndex(line => line.trim().startsWith('='));
        if (index >= 0) {
            let abstract = lines.slice(index + 1, lines.length).join("\n");
            abstract = this.removeInvalidSymbols(abstract);
            return this.truncateAbstract(abstract, this.maxAbstractContentLength);
        } else {
            return null;
        }
    }

    truncateAbstract(text, maxLen) {
        if (text.length > maxLen) {
            return text.substring(0, maxLen);
        } else {
            return text;
        }
    }

    removeInvalidSymbols(abstractText) {
        return abstractText.replace(/[$=_#]/g, '');
    }

    processPost(post) {
        if (post.source === undefined ||
            post.source == null ||
            !(post.source.endsWith(".typ") || post.source.endsWith(".typst"))
        ) {
            return  {
                path: post.path,
                data: post,
                layout: post.layout
            };
        }

        this.info(`start to query abstract ${post.source}`)
        const excerpt = this.typstCli.queryMetadata(post, "abstract", (post, result) => {
            post.excerpt = result;
            this.info(`succeed to find abstract with excerpt tag: excerpt=${post.excerpt}, source=${post.source}`);
        });

        if (excerpt === undefined || excerpt == null) {
            post.excerpt = this.findAbstractInContent(post._content);
            this.info(`succeed to find abstract in content: excerpt=${post.excerpt.slice(0, 10)}, source=${post.source}`);
        }

        return {
            path: post.path,
            data: post,
            layout: post.layout
        }
    }

    info(content) {
        console.log(`[typst-generator-excerpt] ${content}`);
    }
}


module.exports = TypstExcerptGenerator;