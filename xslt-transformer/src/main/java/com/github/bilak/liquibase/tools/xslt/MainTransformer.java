package com.github.bilak.liquibase.tools.xslt;

import java.io.File;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.Configuration;
import net.sf.saxon.TransformerFactoryImpl;
import net.sf.saxon.jaxp.SaxonTransformerFactory;
import net.sf.saxon.s9api.Processor;

/**
 * Main transformation component.
 *
 * @author Lukáš Vasek
 */
public class MainTransformer {

    private static final String XSLT_TEMPLATE_PARAM = "xslt-template";
    private static final String SOURCE_FILE_PARAM = "source-file";
    private static final String RESULT_FILE_PARAM = "result";


    public static void main(String[] args) throws TransformerException {
        final TransformerConfiguration transformerConfiguration = parseArguments(args);
        new MainTransformer().transform(transformerConfiguration);
    }

    public void transform(final TransformerConfiguration transformerConfiguration) throws TransformerException {
        final SaxonTransformerFactory factory = new TransformerFactoryImpl();
        final Configuration saxonConfig = factory.getConfiguration();

        final Processor processor = (Processor) saxonConfig.getProcessor();
        processor.registerExtensionFunction(new UUIDExtension());

        final Transformer transformer = factory.newTransformer(transformerConfiguration.getXsltTemplate());
        transformer.transform(transformerConfiguration.getSourceFile(), transformerConfiguration.getResult());
    }

    private static TransformerConfiguration parseArguments(final String[] args) {
        final List<String> arguments = Arrays.asList(args);

        final Source xsltTemplate = new StreamSource(getRequiredArgument(arguments, XSLT_TEMPLATE_PARAM));
        final Source sourceFile = new StreamSource(getRequiredArgument(arguments, SOURCE_FILE_PARAM));
        final Result result = getArgument(arguments, RESULT_FILE_PARAM)
                .map(res -> new StreamResult(new File(res)))
                .orElseGet(() -> new StreamResult(System.out));

        return new TransformerConfiguration(xsltTemplate, sourceFile, result);
    }


    private static String getRequiredArgument(final List<String> arguments, final String argument) {
        return getArgument(arguments, argument)
                .orElseThrow(() -> new IllegalStateException(String.format("Argument [%s] is required", argument)));
    }

    private static Optional<String> getArgument(final List<String> arguments, final String argument) {
        final String commandLineArgument = toArgument(argument);
        return arguments
                .stream()
                .filter(a -> a.startsWith(commandLineArgument))
                .map(a -> a.replace(commandLineArgument, ""))
                .findFirst();
    }

    private static String toArgument(final String arg) {
        return "--".concat(arg).concat("=");
    }


    static class TransformerConfiguration {

        private final Source xsltTemplate;
        private final Source sourceFile;
        private final Result result;

        TransformerConfiguration(final Source xsltTemplate, final Source sourceFile, final Result result) {
            this.xsltTemplate = xsltTemplate;
            this.sourceFile = sourceFile;
            this.result = result;
        }

        public Source getXsltTemplate() {
            return xsltTemplate;
        }

        public Source getSourceFile() {
            return sourceFile;
        }

        public Result getResult() {
            return result;
        }
    }
}
