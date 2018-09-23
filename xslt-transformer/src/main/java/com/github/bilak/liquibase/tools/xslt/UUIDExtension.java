package com.github.bilak.liquibase.tools.xslt;

import java.util.UUID;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

/**
 * Extension function for {@link java.util.UUID} generation.
 *
 * @author Lukáš Vasek
 */
public class UUIDExtension extends ExtensionFunctionDefinition {

    public static final String PREFIX = "uuid";
    public static final String NAMESPACE = "http://uuid.util.java";
    public static final String FUNCTION_NAME = "new-uuid";

    public StructuredQName getFunctionQName() {
        return new StructuredQName(PREFIX, NAMESPACE, FUNCTION_NAME);
    }

    public SequenceType[] getArgumentTypes() {
        return new SequenceType[0];
    }

    public SequenceType getResultType(final SequenceType[] sequenceTypes) {
        return SequenceType.SINGLE_STRING;
    }

    public ExtensionFunctionCall makeCallExpression() {
        return new ExtensionFunctionCall() {
            @Override
            public Sequence call(final XPathContext xPathContext, final Sequence[] sequences) {
                return new StringValue(UUID.randomUUID().toString());
            }
        };
    }
}
