const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class Processor {
    constructor(hexo) {
        this.hexo = hexo;
        this.renderCli = 'typst-ts-cli';
        this.base_dir = this.hexo.base_dir;

        const postProcessor = require(path.resolve(
            hexo.base_dir,
            `node_modules/hexo/lib/plugins/processor/post`,
        ));
        this.pp = postProcessor(hexo);
    }

    query(data, labelName) {
        const result = JSON.parse(execSync([
            this.renderCli,
            'query',
            '--workspace',
            this.base_dir,
            '--entry',
            `"source/${data.source}"`,
            '--selector',
            `"${labelName}"`
        ].join(' '), {
            encoding: 'utf-8',
        }));

        if (result != null && result.length > 0)
            return result[0]["value"];

        return null;
    }

    queryMetadata(data, labelName, dataProcessor) {
        let result = this.query(data, `<${labelName}>`)
        if (result != null) {
            result = this.split(result);
            this.info(`parse ${data.source}, label name=[${labelName}], result=[${result}]`);
            dataProcessor(data, result);
        } else {
            this.info(`post ${data.source} does not have <${labelName}>`);
        }
    }

    split(content) {
        let substrings = content.split(';');
        return substrings.map(substring => substring.trim());
    }

    info(content) {
        console.log(`[typst] processing   ${content}`);
    }

    process(data) {
        if (!(data.source.endsWith('.typ') || data.source.endsWith('.typst'))) {
            return;
        }
        this.info(`start to processing post [${data.source}]`);

        this.queryMetadata(data, "tags", (data, result) => {
            data.setTags(result);
        });

        this.queryMetadata(data, "categories", (data, result) => {
           data.setCategories(result);
        });

        return data;
    }
}

module.exports = Processor;