const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const TypstCli = require('./typst-cli');

class Processor {
    constructor(hexo) {
        this.hexo = hexo;
        this.typstCli = new TypstCli(hexo);

        const postProcessor = require(path.resolve(
            hexo.base_dir,
            `node_modules/hexo/lib/plugins/processor/post`,
        ));
        this.pp = postProcessor(hexo);
    }

    info(content) {
        console.log(`[typst] processing   ${content}`);
    }

    process(data) {
        if (!(data.source.endsWith('.typ') || data.source.endsWith('.typst'))) {
            return;
        }
        this.info(`start to processing post [${data.source}]`);

        this.typstCli.queryMetadata(data, "tags", (data, result) => {
            data.setTags(result);
        });

        this.typstCli.queryMetadata(data, "categories", (data, result) => {
           data.setCategories(result);
        });

        return data;
    }
}

module.exports = Processor;