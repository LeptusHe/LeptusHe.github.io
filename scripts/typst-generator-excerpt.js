const TypstCli = require("./typst-cli");


class TypstExcerptGenerator {
    constructor(hexo) {
        this.hexo = hexo;
        this.typstCli = new TypstCli(hexo);
    }

    process(local) {
        //console.log(`input type: ${typeof local}, local: ${local.tags}, posts: ${local.posts}`);

        return local.posts.map(post => {
            this.processPost(post);
        });
    }

    processPost(post) {
        //console.log(`processPost: ${post.path}, ${post.content}`);
        if (post.source === undefined || post.source == null) {
            return  {
                path: post.path,
                data: post,
                layout: post.layout
            };
        }

        console.warn(`start to query abstract ${post.source}`)
        this.typstCli.queryMetadata(post, "abstract", (post, result) => {
            post.excerpt = result;
            this.info(`succeed to write excerpt ${post.excerpt}`);
        });

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