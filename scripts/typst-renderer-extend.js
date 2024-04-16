const Processor = require('./Processor');
const processor = new Processor(hexo);

function process(data) {
    return processor.process(data);
}

hexo.extend.filter.register('after_post_render', process);
