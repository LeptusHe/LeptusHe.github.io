const Processor = require('./Processor');
const processor = new Processor(hexo);

function process(data) {
    return processor.process(data);
}
hexo.extend.filter.register('after_post_render', process);



const TypstExcerptGenerator = require("./typst-generator-excerpt");
const typstExcerptGenerator = new TypstExcerptGenerator(hexo);
function generateExcerpt(local) {
    console.log("start to generate excerpt");
    return typstExcerptGenerator.process(local);
}
hexo.extend.generator.register('excerpt', generateExcerpt);