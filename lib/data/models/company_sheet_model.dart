class CompaniesSheet {
  String version;
  String encoding;
  Feed feed;

  CompaniesSheet({this.version, this.encoding, this.feed});

  CompaniesSheet.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    encoding = json['encoding'];
    feed = json['feed'] != null ? Feed.fromJson(json['feed']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['version'] = this.version;
    data['encoding'] = this.encoding;
    if (this.feed != null) {
      data['feed'] = this.feed.toJson();
    }
    return data;
  }
}

class Feed {
  String xmlns;
  String xmlnsOpenSearch;
  String xmlnsBatch;
  String xmlnsGs;
  Id id;
  Id updated;
  List<Category> category;
  Title title;
  List<Link> link;
  List<Author> author;
  Id openSearchTotalResults;
  Id openSearchStartIndex;
  Id gsRowCount;
  Id gsColCount;
  List<Entry> entry;

  Feed(
      {this.xmlns,
      this.xmlnsOpenSearch,
      this.xmlnsBatch,
      this.xmlnsGs,
      this.id,
      this.updated,
      this.category,
      this.title,
      this.link,
      this.author,
      this.openSearchTotalResults,
      this.openSearchStartIndex,
      this.gsRowCount,
      this.gsColCount,
      this.entry});

  Feed.fromJson(Map<String, dynamic> json) {
    xmlns = json['xmlns'];
    xmlnsOpenSearch = json['xmlns\$openSearch'];
    xmlnsBatch = json['xmlns\$batch'];
    xmlnsGs = json['xmlns\$gs'];
    id = json['id'] != null ? Id.fromJson(json['id']) : null;
    updated = json['updated'] != null ? Id.fromJson(json['updated']) : null;
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category.add(Category.fromJson(v));
      });
    }
    title = json['title'] != null ? Title.fromJson(json['title']) : null;
    if (json['link'] != null) {
      link = <Link>[];
      json['link'].forEach((v) {
        link.add(Link.fromJson(v));
      });
    }
    if (json['author'] != null) {
      author = <Author>[];
      json['author'].forEach((v) {
        author.add(Author.fromJson(v));
      });
    }
    openSearchTotalResults = json['openSearch\$totalResults'] != null
        ? Id.fromJson(json['openSearch\$totalResults'])
        : null;
    openSearchStartIndex = json['openSearch\$startIndex'] != null
        ? Id.fromJson(json['openSearch\$startIndex'])
        : null;
    gsRowCount =
        json['gs\$rowCount'] != null ? Id.fromJson(json['gs\$rowCount']) : null;
    gsColCount =
        json['gs\$colCount'] != null ? Id.fromJson(json['gs\$colCount']) : null;
    if (json['entry'] != null) {
      entry = <Entry>[];
      json['entry'].forEach((v) {
        entry.add(Entry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['xmlns'] = this.xmlns;
    data['xmlns\$openSearch'] = this.xmlnsOpenSearch;
    data['xmlns\$batch'] = this.xmlnsBatch;
    data['xmlns\$gs'] = this.xmlnsGs;
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    if (this.updated != null) {
      data['updated'] = this.updated.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category.map((v) => v.toJson()).toList();
    }
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    if (this.author != null) {
      data['author'] = this.author.map((v) => v.toJson()).toList();
    }
    if (this.openSearchTotalResults != null) {
      data['openSearch\$totalResults'] = this.openSearchTotalResults.toJson();
    }
    if (this.openSearchStartIndex != null) {
      data['openSearch\$startIndex'] = this.openSearchStartIndex.toJson();
    }
    if (this.gsRowCount != null) {
      data['gs\$rowCount'] = this.gsRowCount.toJson();
    }
    if (this.gsColCount != null) {
      data['gs\$colCount'] = this.gsColCount.toJson();
    }
    if (this.entry != null) {
      data['entry'] = this.entry.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Id {
  String t;

  Id({this.t});

  Id.fromJson(Map<String, dynamic> json) {
    t = json['\$t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['\$t'] = this.t;
    return data;
  }
}

class Category {
  String scheme;
  String term;

  Category({this.scheme, this.term});

  Category.fromJson(Map<String, dynamic> json) {
    scheme = json['scheme'];
    term = json['term'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['scheme'] = this.scheme;
    data['term'] = this.term;
    return data;
  }
}

class Title {
  String type;
  dynamic t;

  Title({this.type, this.t});

  Title.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    t = json['\$t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['type'] = this.type;
    data['\$t'] = this.t;
    return data;
  }
}

class Link {
  String rel;
  String type;
  String href;

  Link({this.rel, this.type, this.href});

  Link.fromJson(Map<String, dynamic> json) {
    rel = json['rel'];
    type = json['type'];
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['rel'] = this.rel;
    data['type'] = this.type;
    data['href'] = this.href;
    return data;
  }
}

class Author {
  Id name;
  Id email;

  Author({this.name, this.email});

  Author.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null ? Id.fromJson(json['name']) : null;
    email = json['email'] != null ? Id.fromJson(json['email']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.name != null) {
      data['name'] = this.name.toJson();
    }
    if (this.email != null) {
      data['email'] = this.email.toJson();
    }
    return data;
  }
}

class Entry {
  Id id;
  Id updated;
  List<Category> category;
  Title title;
  Title content;
  List<Link> link;
  GsCell gsCell;

  Entry(
      {this.id,
      this.updated,
      this.category,
      this.title,
      this.content,
      this.link,
      this.gsCell});

  Entry.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? Id.fromJson(json['id']) : null;
    updated = json['updated'] != null ? Id.fromJson(json['updated']) : null;
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category.add(Category.fromJson(v));
      });
    }
    title = json['title'] != null ? Title.fromJson(json['title']) : null;
    content = json['content'] != null ? Title.fromJson(json['content']) : null;
    if (json['link'] != null) {
      link = <Link>[];
      json['link'].forEach((v) {
        link.add(Link.fromJson(v));
      });
    }
    gsCell =
        json['gs\$cell'] != null ? GsCell.fromJson(json['gs\$cell']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    if (this.updated != null) {
      data['updated'] = this.updated.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category.map((v) => v.toJson()).toList();
    }
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    if (this.content != null) {
      data['content'] = this.content.toJson();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    if (this.gsCell != null) {
      data['gs\$cell'] = this.gsCell.toJson();
    }
    return data;
  }
}

class GsCell {
  String row;
  String col;
  String inputValue;
  String t;
  String numericValue;

  GsCell({this.row, this.col, this.inputValue, this.t, this.numericValue});

  GsCell.fromJson(Map<String, dynamic> json) {
    row = json['row'];
    col = json['col'];
    inputValue = json['inputValue'];
    t = json['\$t'];
    numericValue = json['numericValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['row'] = this.row;
    data['col'] = this.col;
    data['inputValue'] = this.inputValue;
    data['\$t'] = this.t;
    data['numericValue'] = this.numericValue;
    return data;
  }
}
