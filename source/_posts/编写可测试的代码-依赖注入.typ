#import "./typst-template/blog-template.typinc": *

#show: blog_setting.with(
  title: "编写可测试的代码-依赖注入",
  author: ("Leptus He"),
  paper: "a1"
)

= 测试

在代码中，类与类、类与方法或者其他软件实体之间总是存在着某些依赖关系。例如，假设某个类$A$的对象$a$需要完成某个功能，然而，它需要通过与类$B$的对象$b$的协作才能够完成该功能。在这个过程中，类$B$则成为类$A$的一个依赖。类$B$的对象$b$则成为了一个service对象（服务的提供者），类$A$的对象$a$则是一个client对象（服务的使用者）。

在编写代码时，如果类$A$对类$B$存在依赖，即类$A$完成某个功能需要类$B$提供的某项服务。那么，我们就需要思考一个问题—我们该如何获得一个提供类$A$所需要的服务的对象呢？

= 依赖注入

在一般情况下，类$A$可能会自己创建一个能够提供其所需要的服务的对象，即new出一个提供服务的对象。然而，这种方式存在着一些问题。如果类$A$的代码中采用了new一个提供服务的对象的方式来获得一个service对象，那么这些代码就是存在耦合的，它违背了面向对象编程中的开闭原则(open/closed principle)。因为，如果存在其他能够提供相同服务的类$C$对象，并且类$A$想要使用类$C$对象来作为service对象，那么我们就需要修改类$A$的代码。这时，代码就不再满足"对扩展是开放的，对修改是关闭的“这两个特征了。

在进行单元测试时，被测试类为了完成某个功能可能需要与其他对象进行协作，例如通过文件系统读取文件或者通过数据库系统获取数据。然而，为了保证单元测试的独立性和可重复性，我们一般都会使用mock对象来替代被测试类所依赖的对象，即service对象。通过这种方式，单元测试的正确性只有被测试类有关，而与被依赖的对象无关。因为如果测试结果依赖于某个外部依赖，例如数据库系统，那么每次的测试结果都可能由于数据库的状态不一样从而导致测试结果不一样，这样就无法保证测试的可重复性和独立性了。

然而，如果被测试类的client代码中存在直接通过new的方式获得service对象的代码，由于service对象无法被替换，那么通过mock对象替换被依赖对象的方法就无法使用了，从而会导致了我们无法写出具有独立性和可重复性的单元测试。我们称这段client代码为不可测试的代码。

为了解决上述所讲的client对象和service对象的耦合问题，我们可以使用一种称为 *依赖注入* （*dependency injection*） 的技术。依赖注入是一种将client对象所依赖的service对象注入到client对象中的技术。通过依赖注入技术，client代码中就不再需要直接通过new的方式来获得service对象了，而是通过由其他代码将service对象注入到client对象中的方式来获得service对象，这就解决了client对象和service对象的耦合问题。在面向对象设计中，这样的代码也是满足了开闭原则的，具有可扩展性。在单元测试中，mock对象就能够通过注入的方式来替换实际的service对象，这样也能够保证我们写出的测试具有独立性和可重复性。这样的代码也称为可测试的代码。

= 依赖注入的方式


一般而言，将依赖注入的方式具有两种：

- constructor注入
- setter注入

以下以一个简单的例子来介绍这两种注入方式：

假设存在一个ModelManager，该类负责从磁盘加载一个model文件并创建出一个Model类对象，然而因为Model类对象是由多个\<mesh, material\>对构成的，所以ModelManager无法直接创建Mesh类对象和Material类对象，所以其需要其他对象来创建Mesh类对象和Material类对象，MeshManager类负责从磁盘加载一个mesh文件并创建一个Mesh对象，MaterialManager类负责从磁盘加载一个material文件并创建一个material对象。所以，ModelManager需要MeshManager与MaterialManager的协助才能够完成该功能，即MeshManager和MaterialManager是ModelManager的两个依赖。

以下以这个例子来进行两种注入方式的说明：

== Constructor注入

```cpp
class ModelManager {
public:
    ModelManager(MeshManager *meshManager, MaterialManager *materialManager)
        : mMeshManager(meshManager), mMaterialManager(materialManager)
    {
        if (!meshManager) {
            throw std::exception("mesh mananger must not be null");
        }

        if (!materialManager) {
            throw std::exception("material manager must not be null");
        }
    }

    Model loadModel(const std::string& filePath) {
        // load model by mMeshManager and mMaterialManager
    }

private:
    MeshManager *mMeshManager;
    MaterialManager *mMaterialManager;
}
```

Constructor注入方法是通过将service对象作为constructor的参数来将依赖注入到client类中的。因此，注入的依赖成为了client的状态的一部分。一般而言，如果依赖能够在调用constructor前构造出来，constructor注入方法是首选的依赖注入方法。因为在constructor被调用后，client对象所需要的依赖都已经被满足了，所以constructor注入方法能够保证client对象总是处于一个合法的状态。

Constructor注入的缺点在于缺乏灵活性。当client对象被构造后，它的依赖，即service对象就无法被更改了。在某些情况下，当client对象被构造后，client对象所依赖的service对象可能需要被修改。此时，constructor注入就无法解决这个问题。

== Setter注入

```cpp
class ModelManager {
public:
    ModelManager() : mMeshManager(nullptr), mMaterialManager(nullptr) {}

    void setMeshManager(MeshManager *meshManager) { mMeshManager = meshManager;  }
    void setMaterialManager(MaterialManager *materialManager) { mMaterialManager = materialManager; }

    Model loadModel(const std::string& filePath) {
        validateState();
        // load model by mMeshManager and mMaterialManager
    }

private:
    bool validateState() const {
        if (!meshManager) {
            throw std::exception("mesh mananger must not be null");
        }
        if (!materialManager) {
            throw std::exception("material manager must not be null");
        }
    }

private:
    MeshManager *mMeshManager;
    MaterialManager *mMaterialManager;
}
```

Setter注入方法主要是通过提供一个setter函数来注入依赖。它的优点在于能够灵活地注入service对象。在任意时刻，client对象所依赖的service对象都能够被更改。然而，由于service对象的注入时间不确定，从而导致在需要使用service对象时，client对象都需要查看service对象是否已经被注入。当需要使用service对象，而其未被注入时，client对象就处于不合法的状态，导致我们需要编写额外的代码来对这种情况进行处理，从而增加了代码量和其他负担。

== Constructor注入和Setter注入的结合

```cpp
class ModelManager {
public:
    ModelManager(MeshManager *meshManager, MaterialManager *materialManager)
        : mMeshManager(meshManager), mMaterialManager(materialManager)
    {
        if (!meshManager) {
            throw std::exception("mesh mananger must not be null");
        }

        if (!materialManager) {
            throw std::exception("material manager must not be null");
        }
    }

    void setMeshManager(MeshManager *meshManager) {
        assert(meshManager != nullptr);
        mMeshManager = meshManager;
    }

     void seaMaterialManager(MaterialManager *materialManager) {
        assert(mMaterialManager != nullptr);
        mMaterialManager = materialManager;
     }

    Model loadModel(const std::string& filePath) {
        // load model by mMeshManager and mMaterialManager
    }

private:
    MeshManager *mMeshManager;
    MaterialManager *mMaterialManager;
}
```

通过结合constructor注入和setter注入方法，我们能够同时拥有两种注入方法的优点，并没有了两种注入方式的缺点。如上所示，在client对象被构造后，其处于一个合法的状态。并且，通过setter函数能够随时替换service对象并保持client对象状态的合法性。

通过两种注入方式的结合，在使用service对象时，我们总能够确保service对象时存在的，从而不用进行验证查找service对象是否存在，进而避免了需要编写异常处理代码的需要。

= References


1. #link("https://en.wikipedia.org/wiki/Dependency_injection")[Dependency injection[wiki]]
2. #link("https://agostini.tech/2017/03/27/using-dependency-injection/")[Using Dependency Injection[Dejan Agostini][2017]]
3. #link("https://agostini.tech/2017/04/24/unit-tests-with-dependency-injection/")[Unit Tests with Dependency Injection[Dejan Agostini][2017]]
