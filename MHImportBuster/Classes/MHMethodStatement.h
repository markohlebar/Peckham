//
//  MHMethodStatement.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 01/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHStatement.h"

@interface MHMethodStatement : MHStatement

@end

@interface MHClassMethodDeclarationStatement : MHMethodStatement

@end

@interface MHInstanceMethodDeclarationStatement : MHMethodStatement

@end

@interface MHClassMethodImplementationStatement : MHMethodStatement

@end

@interface MHInstanceMethodImplementationStatement : MHMethodStatement

@end
