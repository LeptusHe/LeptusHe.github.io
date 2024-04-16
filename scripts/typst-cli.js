const { execSync } = require('child_process');

class TypstCli {
    constructor(hexo) {
        this.hexo = hexo;
        this.renderCli = 'typst-ts-cli';
        this.base_dir = this.hexo.base_dir;
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
            return result;
        } else {
            this.info(`post ${data.source} does not have <${labelName}>`);
            return null;
        }
    }

    split(content) {
        let substrings = content.split(';');
        return substrings.map(substring => substring.trim());
    }

    info(content) {
        console.log(`[typst] processing   ${content}`);
    }
}

module.exports = TypstCli;